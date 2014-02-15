Persistent expectations
====

An RSpec example usually consists of some code to set up the situation being tested, and some code called an _expectation_ that defines the expected outcome.
As discussed in the {file:Pins.md Pins page}, to write an expectation that the main output pin is driving high you could write:

    !!!ruby
    expect(main_output).to be_driving_high

This is fine, but it is not a great way to test firmware because (unless you put it in a loop or method) it only runs once, at one particular cycle of the simulation.  It will not catch any accidental glitches on the main output pin that occur at a later time.

RPicSim helps to address this by adding a new feature to RSpec examples called "persistent expectations".
Persistent expectations are implemented in the module {RPicSim::RSpec::PersistentExpectations}, which is part of RPicSim's {file:RSpecIntegration.md RSpec integration}.

Usage
----

To set a persistent expectation, call the {RPicSim::RSpec::PersistentExpectations#expecting expecting} method inside an RSpec example or a before/after hook:

    !!!ruby
    expecting main_output => be_driving_high

The argument to `expecting` is a hash with the objects being tested as the keys, and the matchers they are being tested against as the values.  You can specify multiple persistent expectations on different objects:

    !!!ruby
    expecting main_output => be_driving_high, error_output => be_drving_low

You can not specify multiple persistent expectations that apply to the same object.  If you specify a persistent expectation for an object that already had one, the latest one you specify will override the previous one.

To remove a persistent expectation, specify a matcher of `nil`:

    !!!ruby
    expecting main_output => nil

If `expecting` is given a block, expectations will only be valid for the duration of the block:

    !!!ruby
    # Verify that the main output stays high for 10 cycles.
    expecting main_output => be_driving_high do
      # The expectation will be checked within the block.
      run_cycles 10
    end
    # The expectation will not be checked here.

The persistent expectations will not be checked immediately when they are added, but they will be checked after every step of the simulation.
You can also check them at any time by calling `check_expecations` inside your RSPec example.

Persistent expectations, when combined with RSpec's `satisfy` matcher, are very powerful.  If `counter` is a {RPicSim::Variable variable} in your simulation, you could use this code to ensure that `counter` never goes above 120:

    !!!ruby
    expecting counter => satisfy { |c| c.value <= 120 }

Persistent expectations are implemented in a straightforward way: the expectations are stored in a hash that is an instance variable of the RSpec example, and the expectations are checked after every step via a hook that is registered with {RPicSim::Sim#every_step} when the simulation is started.

Example
----

The following RSpec example tests that the main output pin is held low (after giving the device some time to start up), but then it goes high after the main input goes high:

    !!!ruby
    it "mirrors the main input onto the main output pin" do
      run_cycles 120    # Give the device time to start up.

      expecting main_output => be_driving_low
      run_cycles 800

      main_input.set true

      # Turn off the persistent expectation temporarily to give the device
      # time to detect the change in the input.
      expecting main_output => nil
      run_cycles 200

      expecting main_output => be_driving_high
      run_cycles 800
    end

In the above example, we removed the persistent expectation on `main_output` temporarily because the device was in a transitionary period and we didn't know exactly when the transition would happen.
We chose to stop monitoring the pin for the duration of the transition and then start monitoring it later, at which point we expect the pin to be in its new state.
We can rewrite that using block arguments instead of explicitly clearing the expectation:

    !!!ruby
    it "mirrors the main input onto the main output pin" do
      run_cycles 120    # Give the device time to start up.

      expecting main_output => be_driving_low do
        run_cycles 800
      end

      main_input.set true

      # Give the device time to detect the change in the input.
      run_cycles 200

      expecting main_output => be_driving_high do
        run_cycles 800
      end
    end

If you need to repeat this patten many times in your tests, you might consider adding a method in `spec_helper.rb` to help you do it:

    !!!ruby
    def transition(opts={})
      opts = opts.dup
      cycles = opts.delete(:cycles) || 50
      opts.keys.each { |k| expectations.delete k }
      run_cycles cycles
      expectations.merge! opts
      check_expectations
    end

Then the test above could become:

    !!!ruby
    it "mirrors the main input onto the main output pin" do
      run_cycles 120    # Give the device time to start up.

      expecting main_output => be_driving_low
      run_cycles 800

      main_input.set true

      transition main_output => be_driving_high
      run_cycles 800
    end

The `transition` method above does not check anything about the main output during the transition time, so unfortunately it might miss any glitches that happen during that time.
Also, it is not very general.
For these reasons, it has not been integrated into the RPicSim code and you will need to copy it to your `spec_helper.rb` file yourself if you want to use it.