Stubbing
====

Stubbing is a technique used in {file:UnitTesting.md unit testing} to replace a routine in a system under test with a simpler routine whose behavior can be specified in the test.
Stubbing allows you to limit the amount of code you are testing, which can make that test easier to design and faster to run.
RPicSim does not have any special features to support stubbing, but it can easily be accomplished using features already present.


A basic stub
----

To stub a method in the most basic way, you can do something like this:

    !!!ruby
    every_step do
      if pc.value == label(:foo).address
        sim.return
      end
    end

The example above just alters our simulation so that whenever the `foo` subroutine is called, instead of running as normal it will return immediately using {RPicSim::Sim#return}.

The example above can be expanded in many ways:
You might read and write from {file:Variables.md variables} and {file:SFRs.md SFRs}.
You might record information about how the subroutine was called.


A stub that counts
----

If you want to know how many times the stubbed routine is called, you could do this:

    !!!ruby
    @foo_count = 0
    every_step do
      if pc.value == label(:foo).address
        @foo_count += 1
        sim.return
      end
    end

Using a Ruby instance variable `@foo_count` instead of a simple local variable means that this code could go in a before hook and the code that checks the count could be in the main part of the RSpec example.


A stub that records parameters
----

You might want to test that the right parameters are getting supplied to the stubbed routine.
To capture information about the stubbed routine's parameters or anything else about the state of the simulation, you could use a Ruby array:

    !!!ruby
    @foo_calls = []
    every_step do
      if pc.value == label(:foo).address
        @foo_calls << { a: foo_param_a.value, b: foo_param_b.value }
        sim.return
      end
    end

In your RSpec examples, you can test that the routine was called the right number of times and with the expected parameters:

    !!!ruby
    expect(@foo_calls).to eq [ {a: 1, b: 25}, {a: 2, b: 24 } ]


LongDelay example
----

This is a more complete example showing how to make a simple stub that counts the number of times it was called.

Here is a minimal MPASM assembly program with two routines.
The `bigDelay` routine delays for a long time using a 16-bit counter and a loop.
The `cooldown` routine either calls `bigDelay` once or twice depending on some condition.

    !!!plain
      #include p10F322.inc
      __config(0x3E06)
      udata
    hot res 1
    counter res 2
      code 0

    cooldown:
      btfsc hot, 0
      call bigDelay
      call bigDelay
      return

    bigDelay:
      movlw   255
      movwf   counter
      movlw   255
      movwf   counter + 1
    delayLoop:
      decfsz  counter, F
      goto    delayLoop
      decfsz  counter+1, F
      goto    delayLoop
      return
      end

Suppose we want to write a unit test for the logic in the `cooldown` method.
We could just run the subroutine in various conditions and see how long it takes to finish.
However, that test could be very slow to run.
Instead, we should stub the `bigDelay` method and make the stub count how many times it was called.

In `spec/spec_helper.rb`, we make a simulation class that points to the compiled COF file.  There is nothing special here:

    !!!ruby
    require 'rpicsim/rspec'

    class LongDelay < RPicSim::Sim
      device_is "PIC10F322"
      filename_is File.dirname(__FILE__) + "../firmware/dist/firmware.cof"
      def_var :hot, :u8
    end

In `spec/cooldown_spec.rb`, we stub the `bigDelay` routine and test `cooldown` to make sure it calls `bigDelay` the right number of times:

    !!!ruby
    require 'rpicsim/rspec'

    describe "cooldown" do
      before do
        start_sim Firmware::LongDelay

        # Stub the "bigDelay" function because it takes a long time to run.
        # Also, count how many times it was called.
        @big_delay_count = 0
        every_step do
          if pc.value == label(:bigDelay).address
            @big_delay_count += 1
            sim.return
          end
        end
      end

      context "when the room is cool" do
        before do
          hot.value = 0
        end

        it "only does one big delay" do
          run_subroutine :cooldown, cycle_limit: 100
          expect(@big_delay_count).to eq 1
        end
      end

      context "when the room is hot" do
        before do
          hot.value = 1
        end

        it "does two big delays" do
          run_subroutine :cooldown, cycle_limit: 100
          expect(@big_delay_count).to eq 2
        end
      end
    end

This makes our test much faster and allows us to just test the behavior of the `cooldown` routine.