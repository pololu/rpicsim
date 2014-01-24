Debugging
====

RPicSim makes it easier to fix firmware bugs that you have found.
With RPicSim, you have access to the entire state of the simulation at every step.
You can see exactly how your code is behaving without having to hook up an oscilloscope or add debugging signals.

Suppose you are writing an RSpec-based integration test that fails with the following error message:

    !!!plain
    ................................................F.....

    Failures:

      1) FooWidget when exposed to 1.5 ms pulses behaves correctly
         Failure/Error: run_microseconds 1500
           expected INTCON to satisfy block
         # ./lib/rpicsim/rspec/persistent_expectations.rb:29:in `check_expectations'
         # ./lib/rpicsim/rspec/persistent_expectations.rb:27:in `check_expectations'
         # ./lib/rpicsim/rspec/helpers.rb:25:in `start_sim'
         # ./lib/rpicsim/pic.rb:574:in `step'
         # ./lib/rpicsim/pic.rb:716:in `run_to_cycle_count'
         # ./lib/rpicsim/pic.rb:708:in `run_cycles'
         # ./spec/foo_widget_spec.rb:10:in `(root)'

         Simulated PIC cycle count: 78963

         Simulated PIC stack trace:
         0x01A0 = startMotor
         0x0044 = motorService+0x14
         0x0B12 = mainLoop+0x2
         0x008C = start2

    Finished in 4.55 seconds
    44 examples, 1 failure

    Failed examples:

    rspec ./spec/example/nice_error_spec.rb:8 # FooWidget when exposed to 1.5ms pulses behaves correctly

In this example, we had a {file:PersistentExpectations.md persistent expectation} asserting something about the INTCON SFR and and at some point in a lengthy integration test our expectation failed.

The stack trace gives us a big clue about what code might be causing the problem.
If we want to inspect the situation more carefully, we could use `run_to_cycle_count 78950` to run the simulation to a point just a few cycles before the error happened and then insert code at the point to do something special.
Two different options are described below.


Logging
----
One option for debugging is to print some debugging information to the console after each step.
For example, we might insert this code into the appropriate point in the RSpec example that is failing:

    !!!ruby
    run_to_cycle_count 78950
    100.times do
      step
      puts pc_description + "  wreg=" + wreg.value.to_s)
    end

This code runs until the cycle count of the simulation is 78950, and then it starts printing debugging information for the next 100 steps.
This example prints a friendly description of the program counter's value and the current value of WREG, but it could be changed to print other things.


Interactive debugging
----
You can also start an interactive session that allows you to manipulate the simulation and inspect its state.
This section shows how to use the ruby-debug gem, but there are other tools that could probably do the same thing (Ripl, PRY, and IRB).

First, install ruby-debug by running:

    !!!plain
    jgem install ruby-debug

In the test that is failing, choose the point where you want to start the interactive session and insert this code:

    !!!plain
    require 'ruby-debug'; debugger

For best results when using the debugger, you need to provide the `--debug` option to JRuby.  From bash, you can do this by running a command like

    !!!plain
    RUBYOPT=--debug rspec

If you are using a Windows Command Prompt, you need to set the environment with the `set` command before running RSpec:

    !!!plain
    set RUBYOPT=--debug
    rspec

This debugger provides many commands, but the only one you really need is the `p` command because it can run arbitrary code.
To advance the simulation by one step and print a friendly description of where the program counter is pointing, you could run `p step; p pc_description` as shown below:

    !!!plain
    (rdb:1) p step; p pc_description
    nil
    "0x0044 = motorService+0x0E"
