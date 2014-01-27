Running the simulation
====

Any useful PIC simulation needs to run for some number of steps and then stop.  RPicSim provides a variety of ways to specify what code to run and when to stop running.  This page is a guide to the following methods of {RPicSim::Pic}:

* {RPicSim::Pic#step step}
* {RPicSim::Pic#run_steps run_steps}
* {RPicSim::Pic#run_cycles run_cycles}
* {RPicSim::Pic#run_to_cycle_count run_to_cycle_count}
* {RPicSim::Pic#run_microseconds run_microseconds}
* {RPicSim::Pic#run_to run_to}
* {RPicSim::Pic#run_subroutine run_subroutine}
* {RPicSim::Pic#goto goto}

Each of these methods has a delegator provided by RPicSim's {file:RSpecIntegration.md RSpec integration}, so in your RSpec examples you can just call them by writing something like `step` and that will have the same effect as `pic.step`.
This applies to all the methods listed above, not just `step`.

Single-stepping
----

The {RPicSim::Pic#step} method is the most basic way to run the simulation.
It executes a single PIC instruction.
The program counter will be updated to point to the next instruction, and the {RPicSim::Pic#cycle_count cycle count} will be increased by the number of cycles that the instruction took.
This method might do some interesting things at times when the CPU is stalled (i.e. during a flash write) or during sleep and that behavior has not been characterized.

The `step` method is the most basic way to run a simulation, and all the `run_*` methods described here call `step` in order to actually run the simulation.

If you want to run a bit of code after each step, see {RPicSim::Pic#every_step} and {file:PersistentExpectations.md Persistent expectations}.

Running for a set time
----

RPicSim provides several different ways to run the simulation for a set amount of "time".

The {RPicSim::Pic#run_steps run_steps} method just runs the `step` method the specified number of times:

    !!!ruby
    run_steps 10   # runs the simulation for 10 steps

The {RPicSim::Pic#run_cycles run_cycles} method runs the simulation until a certain number of instruction cycles have elapsed, using {RPicSim::Pic#cycle_count}:

    !!!ruby
    run_cycles 20  # runs the simulation for approximately 20 instruction cycles

The {RPicSim::Pic#run_to_cycle_count run_to_cycle_count} method is similar to `run_cycles`, but it takes as an argument the total number of cycles since the simulation was started, and it runs up to that point:

    !!!ruby
    run_to_cycle_count 1000  # runs the simulation until the total cycle count is 1000

The {RPicSim::Pic#run_microseconds} method runs the simulation for the specified number of microseconds of simulated time.  Before running this method, you need to tell RPicSim how fast the simulated PIC is running by setting the {RPicSim::Pic#frequency_mhz} attribute.  For example:

    !!!ruby
    before do
      start_sim MySim
      pic.frequency_mhz = 4
    end

The `frequency_mhz` attribute can be changed during the simulation in order to model a firmware that changes its own clock speed.

Once you have set `frequency_mhz`, you can use `run_microseconds` or its more readable UTF-8 alias `run_µs`:

    !!!ruby
    run_microseconds 15   # run for approximately 15 microseconds
    run_µs 15             # same

To use `run_µs`, be sure to configure your text editor to save files using UTF-8 encoding, and put a comment at the very top line of your file that says `# coding: UTF-8`.
If you don't do this, you might get an "invalid byte sequence in US-ASCII" error.

Regarding time accuracy:  Certain instructions take two cycles and there is no way to stop the simulation in the middle of an instruction, so both `run_cycles` and `run_microseconds` will sometimes run the simulation one cycle longer than requested.
These one-cycle errors can accumulate if you call the method many times.
Therefore, if you need to test something with high time-precision (like a software serial library) you might need to do something more complex using {RPicSim::Pic#cycle_count} and {RPicSim::Pic#step}.


Running until a condition is met
----

The most versatile method for running a simulation is {RPicSim::Pic#run_to run_to}.

For its first argument, the `run_to` method takes either a single condition or an array of conditions.
A condition can be many different things as shown in the examples below.
The `run_to` method will run the simulation until one of the conditions is met and then stop.

The second argument to `run_to` is an optional hash of options.
It is recommended to always specify the `cycle_limit` option, which limits how the long simulation
can run, in order to avoid an accidental infinite loop in your tests.
If the limit is exceeded, an exception is raised.

For example, to run to a label named "apple":

    !!!ruby
    run_to :apple, cycle_limit: 100

To run until either the "step2" label is reached or the current subroutine returns:

    !!!ruby
    run_to [ :step2, :return ], cycle_limit: 200

When `run_to` finishes, it will return the object representing the condition that was met.
This can be helpful in tests:

    !!!ruby
    result = run_to [ :step2, :return ], cycle_limit: 200
    expect(result).to eq :step2

To run until an arbitrary condition is met:

    !!!ruby
    run_to Proc.new { wreg.value == 2 }, cycle_limit: 300

To run to a particular address:

    !!!ruby
    run_to 0x2000, cycle_limit: 300

To finish running a subroutine and assert that it takes between 10000 and 11000 cycles to finish:

    !!!ruby
    run_to :return, cycles: 10000..11000

For the complete, formal documentation of `run_to`, see {RPicSim::Pic#run_to}.


Running a small piece of code
----

It is possible to use {RPicSim::Pic#goto} and {RPicSim::Pic#run_to} together to just run a small piece of the firmware without regard for the rest.
This can be useful for unit tests.
For example, this code moves the PIC's program counter to point to the address of the "loopStart" label and then run the simulation until it reaches loopEnd:

    goto :loopStart
    run_to :loopEnd, cycle_limit: 400


Running a subroutine or function
----

One of the most useful methods for unit tests is {RPicSim::Pic#run_subroutine}.  This method is the easiest way to test a subroutine or function in your program in isolation from other things.  It runs the given subroutine until it returns (e.g. with a RETURN or RETLW instruction).

The first argument should be a label name (or any valid argument to {RPicSim::Pic#location_address}), and the second argument is an optional hash of options that supports the same options as {RPicSim::Pic#run_to run_to}.

For example, to test a subroutine that drives the `main_output` pin high:

    run_subroutine :drivePinHigh, cycle_limit: 20
    main_output.should be_driving_high

In this example, `main_output` is a pin alias, as described in the {file:Pins.md Pins page}.

Some subroutine values might store input or output values in RAM.  To test those subroutines, you will need to be able to read and write RAM as described in the {file:Variables.md Variables page}.

Some subroutine values might store input or output values in SFRs.  To test those subroutines, you will need to be able to read and write SFRs as described in the {file:SFRs.md SFRs page}.