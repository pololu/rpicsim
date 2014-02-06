Pins
====

The only way a PIC microcontroller can have an effect on the world is through its pins, so pins are an important part of a PIC simulation.
RPicSim exposes the modeling of pins that the MPLAB X simulator provides.
Each {RPicSim::Sim} simulation object contains a collection of {RPicSim::Pin} objects, one for each external pin of the device.
Using a Pin object, you can detect whether the pin is an input or an output.
If it is an output, you can detect whether the output is driving high or driving low.
If it is an input, you can set the simulated value of the input.

Getting a Pin object
----

The {RPicSim::Sim#pin} method can be called on your simulation object to retrieve a {RPicSim::Pin} object.
If you are using RPicSim's {file:RSpecIntegration.md RSpec integration}, the `pin` method inside an example automatically redirects to the simulation object so you can use it easily like this:

    !!!ruby
    it "works" do
      pin(:RA1)  # => returns a Pin object
    end

The first argument of {RPicSim::Sim#pin} should be the name of the pin as a symbol.
The allowed names come from the MPLAB X code, but they should match the names given in the PIC datasheet.
For example, the PIC10F322 pin RA1 can be referred to by many names, including `:RA1`, `:PWM2`, `:AN1`, and `:NCO1CLK`.

RPicSim does not model the GND and VDD pins.

Pin aliases
----

To make your tests readable and protect against future schematic changes, you should try to refer to pins by an application-specific name like "main output" instead of a datasheet name like RA1.  RPicSim provides a feature to help you do this called a _pin alias_.

Within your {file:DefiningSimulationClass.md simulation class definition}, call {RPicSim::Sim::ClassDefinitionMethods#def_pin def_pin} to define your pins.
For example:

    !!!ruby
    class MySim < RRicSim::Sim
      #...
      
      def_pin :main_output, :RA1
      
    end

This makes `:main_output` be an alias for `:RA1`.  You can now access the Pin object by passing `:main_output` as the argument to {RPicSim::Sim#pin}:

    !!!ruby
    pin(:main_output)
    
Defining a pin alias also adds a "shortcut" method by the same name.  This means that you can access the pin like this:

    !!!ruby
    sim.main_output
    
The shortcuts are also available in RSpec thanks to RPicsim's {file:RSpecIntegration.md RSpec integration}, so you can simply write `main_output` in any of your RSpec examples:

    !!!ruby
    it "drives the main output high" do
      expect(main_output).to be_driving_high
    end
    
Note that since the shortcuts are available in many places, your pin names might conflict with names defined in other places.


Pin methods
----

Once you have a Pin object, you can call any of the methods listed in {RPicSim::Pin} on it.  These methods allow you to ask about the state of the Pin and to set the simulated input value of an input pin.


Issues
----

The modelling of Pins provided by the MPLAB X simulator is fairly new and there are still some bugs in it.
For example, you might need to clear the ANSELx bit of a pin in your firmware before trying to set its output value, or else the simulator will mistakenly think your pin is driving low.
For more information, see the {file:KnownIssues.md Known issues page}.


PinMirror example
----

This section contains a simple example showing how to apply the information above and use {RPicSim::Pin} objects.

Here is a minimal MPASM assembly program for the PIC10F322 that continuously reads the value from an input pin (RA0) and copies it to an output pin (RA1):

    !!!plain
      #include p10F322.inc
      __config(0x3E06)
      code 0
      clrf  ANSELA
      bcf   TRISA, 1
    loopStart
      btfss PORTA, 0
      bcf   LATA, 1
      btfsc PORTA, 0
      bsf   LATA, 1
      goto  loopStart
      end

In `spec/spec_helper.rb`, we make a simulation class that points to the compiled COF file and defines some pin aliases:

    !!!ruby
    require 'rpicsim/spec_helper'
    
    class PinMirror < RPicSim::Pic
      device_is "PIC10F322"
      filename_is File.dirname(__FILE__) + "../firmware/dist/firmware.cof"
        
      def_pin :main_input, :RA0
      def_pin :main_output, :RA1
    end
    
In `spec/pin_mirror_spec.rb`, we write a simple test that changes the input and makes sure that the output changes accordingly:

    !!!ruby
    require_relative 'spec_helper'

    describe "PinMirror" do
      before do
        start_sim PinMirror
      end

      it "continuously mirrors" do
        main_input.set false
        run_cycles 10
        expect(main_output).to be_driving_low

        run_cycles 10
        expect(main_output).to be_driving_low

        main_input.set true
        run_cycles 10
        expect(main_output).to be_driving_high

        run_cycles 10
        expect(main_output).to be_driving_high
        
        main_input.set false
        run_cycles 10
        expect(main_output).to be_driving_low
      end
    end

The calls to {RPicSim::Pic#run_cycles} are needed to give the simulated device enough time to react to the change on its input.
