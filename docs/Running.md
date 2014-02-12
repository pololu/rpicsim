Running the simulation
====

Any useful microcontroller simulation needs to run for some number of steps and then stop.  RPicSim provides a variety of ways to specify what code to run and when to stop running.  This page is a guide to the following methods of {RPicSim::Sim}:

* {RPicSim::Sim#step step}
* {RPicSim::Sim#run_steps run_steps}
* {RPicSim::Sim#run_cycles run_cycles}
* {RPicSim::Sim#run_to_cycle_count run_to_cycle_count}
* {RPicSim::Sim#run_to run_to}
* {RPicSim::Sim#run_subroutine run_subroutine}
* {RPicSim::Sim#goto goto}

Each of these methods has a delegator provided by RPicSim's {file:RSpecIntegration.md RSpec integration}, so in your RSpec examples you can just call them by writing something like `step` and that will have the same effect as `sim.step`.
This applies to all the methods listed above, not just `step`.

Single-stepping
----

The {RPicSim::Sim#step} method is the most basic way to run the simulation.
It executes a single instruction.
The program counter will be updated to point to the next instruction, and the {RPicSim::Sim#cycle_count cycle count} will be increased by the number of cycles that the instruction took.
This method might do some interesting things at times when the CPU is stalled (i.e. during a flash write) or during sleep and that behavior has not been characterized.

The `step` method is the most basic way to run a simulation, and all the `run_*` methods described here call `step` in order to actually run the simulation.

If you want to run a bit of code after each step, see {RPicSim::Sim#every_step} and {file:PersistentExpectations.md Persistent expectations}.

Running for a set time
----

RPicSim provides several different ways to run the simulation for a set amount of "time".

The {RPicSim::Sim#run_steps run_steps} method just runs the `step` method the specified number of times:

    !!!ruby
    run_steps 10   # runs the simulation for 10 steps

The {RPicSim::Sim#run_cycles run_cycles} method runs the simulation until a certain number of instruction cycles have elapsed, using {RPicSim::Sim#cycle_count}:

    !!!ruby
    run_cycles 20  # runs the simulation for approximately 20 instruction cycles

The {RPicSim::Sim#run_to_cycle_count run_to_cycle_count} method is similar to `run_cycles`, but it takes as an argument the total number of cycles since the simulation was started, and it runs up to that point:

    !!!ruby
    run_to_cycle_count 1000  # runs the simulation until the total cycle count is 1000

Regarding time accuracy:  Certain instructions take two cycles and there is no way to stop the simulation in the middle of an instruction, so the simulation will sometimes run one cycle longer than requested when calling one of the methods described on this page.
Therefore, if you need to test something with high time-precision (like a software serial library) you might need to do something more complex using {RPicSim::Sim#cycle_count} and {RPicSim::Sim#step}.


Running until a condition is met
----

The most versatile method for running a simulation is {RPicSim::Sim#run_to run_to}.

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

For the complete, formal documentation of `run_to`, see {RPicSim::Sim#run_to}.


Running a small piece of code
----

It is possible to use {RPicSim::Sim#goto} and {RPicSim::Sim#run_to} together to just run a small piece of the firmware without regard for the rest.
This can be useful for unit tests.
For example, this code moves the devices's program counter to point to the address of the "loopStart" label and then runs the simulation until it reaches loopEnd:

    goto :loopStart
    run_to :loopEnd, cycle_limit: 400


Running a subroutine or function
----

One of the most useful methods for unit tests is {RPicSim::Sim#run_subroutine}.  This method is the easiest way to test a subroutine or function in your program in isolation from other things.  It runs the given subroutine until it returns (e.g. with a RETURN or RETLW instruction).

The first argument should be a label name (or any valid argument to {RPicSim::Sim#location_address}), and the second argument is an optional hash of options that supports the same options as {RPicSim::Sim#run_to run_to}.

For example, to test a subroutine that drives the `main_output` pin high:

    run_subroutine :drivePinHigh, cycle_limit: 20
    main_output.should be_driving_high

In this example, `main_output` is a pin alias, as described in the {file:Pins.md Pins page}.

Some subroutine values might store input or output values in RAM.  To test those subroutines, you will need to be able to read and write RAM as described in the {file:Variables.md Variables page}.

Some subroutine values might store input or output values in SFRs.  To test those subroutines, you will need to be able to read and write SFRs as described in the {file:SFRs.md SFRs page}.