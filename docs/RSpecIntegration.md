RSpec integration
====

RPicSim has optional code that allows you to integrated it nicely with RSpec.
RPicSim's RSpec integration is mainly designed to help you write shorter, less verbose tests, but it also provides helpful error messages when a test fails.
Most of the example code in this manual assumes that you have the RSpec integration enabled.

Turning on RSpec integration
----

To enable the RSpec integration, simply put this line in your `spec_helper.rb`:

    !!!ruby
    require 'rpicsim/rspec'

The features that this gives you are documented below.


Helper methods
----

Requiring "rpicsim/rspec" causes the {RPicSim::RSpec::Helpers} module to get included (i.e. mixed in) to all of your RSpec examples.

This module provides the {RPicSim::RSpec::Helpers#start_sim start_sim} method and the methods described on the {file:PersistentExpectations.md persistent expectations page}.
You can call `start_sim` in an example or a before hook to start a new simulation.
The simulation object can then be accessed with by typing `sim` in your examples.

### Basic shortcuts

Unless you disable them, calling `start_sim` will also give you access to over a dozen basic shortcut methods like `pin` and `run_to` in your RSpec examples.
The full list of basic shortcuts can be found in {RPicSim::Sim::BasicShortcuts::ForwardedMethods}.
You can call these by simply typing a method name in an RSpec example:

    !!!ruby
    run_to :foo    # equivalent to sim.run_to :foo


### Firmware-specific shortcuts

Unless you disable them, you will get access to firmware-specific shortcuts defined by the simulation.
These shortcuts correspond to items defined with {RPicSim::Sim::ClassDefinitionMethods#def_var def_var}, {RPicSim::Sim::ClassDefinitionMethods#def_flash_var def_flash_var} and {RPicSim::Sim::ClassDefinitionMethods#def_pin def_pin}.

For example, if your {file:DefiningSimulationClass.md simulation class} defines a pin named `main_output`, then you can just write code like this in your RSpec examples:

    !!!ruby
    expect(main_output).to be_driving_high

You can disable the firmware-specific shortcuts in your RSpec examples, but they will still be available on the simulation object itself (e.g. `sim.main_output`).

### Configuring shortcuts

RPicSim provides a custom RSpec configuration option called `sim_shortcuts` that can either be set to `:all` (default), `:basic`, or `:none`.

If you just want to use the basic shortcuts and not the firmware-specific shortcuts, add the following code to your `spec_helper.rb`:

    !!!ruby
    RSpec.configure do |config|
      config.sim_shortcuts = :basic
    end

To turn off all the shortcuts, use:

    !!!ruby
    RSpec.configure do |config|
      config.sim_shortcuts = :none
    end


Diagnostic information
----

If an error happens in a test (either from an expectation failing or from a general exception being raised), RPicSim augments the default output of RSpec in order to provide additional information about the state of the simulation.
When an RSpec example fails, the output you get will look something like this:

    !!!plain
    ................................................F.....

    Failures:

      1) FooWidget when exposed to 1.5 ms pulses behaves correctly
         Failure/Error: run_cycles 1500*4
           expected INTCON to satisfy block
         # ./lib/rpicsim/rspec/persistent_expectations.rb:29:in `check_expectations'
         # ./lib/rpicsim/rspec/persistent_expectations.rb:27:in `check_expectations'
         # ./lib/rpicsim/rspec/helpers.rb:25:in `start_sim'
         # ./lib/rpicsim/sim.rb:574:in `step'
         # ./lib/rpicsim/sim.rb:716:in `run_to_cycle_count'
         # ./lib/rpicsim/sim.rb:708:in `run_cycles'
         # ./spec/foo_widget_spec.rb:10:in `(root)'

         Simulation cycle count: 78963

         Simulation stack trace:
         0x01A0 = startMotor
         0x0044 = motorService+0x14
         0x0B12 = mainLoop+0x2
         0x008C = start2

    Finished in 4.55 seconds
    44 examples, 1 failure

    Failed examples:

    rspec ./spec/example/nice_error_spec.rb:8 # FooWidget when exposed to 1.5ms pulses behaves correctly

In this example, we had a {file:PersistentExpectations.md persistent expectation} asserting something about the INTCON SFR and and at some point in a lengthy integration test our expectation failed.
The "Simulation cycle count" shows us the value of {RPicSim::Sim#cycle_count} at the time that the error happened.
The "Simulation stack trace" shows us what addresses were on the device's call stack.
(Actually, the call stack stores the addresses the process will return to, but this stack trace shows the addresses where calls occurred, which is one or two less than the return address.)
This information can help when you are {file:Debugging.md debugging} issues.


Better RSpec error messages
----

RPicSim also overrides some of RSpec's error messages to be better.

For example, instead of just saying an error message like "expected driving_high? to return true, got false", RSpec will actually say what object it called `driving_high?` on.
This feature is important when you are using {file:PersistentExpectations.md persistent expectations} and want to know which expectation failed, because the stack trace will not help.