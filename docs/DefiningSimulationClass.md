Defining your simulation class
====

In order to run a simulation of your firmware using RPicSim, you must make a new subclass of {RPicSim::Sim}.  This class is called your _simulation class_. Below is an example:

    class MySim < RPicSim::Sim
      device_is "PIC10F322"
      filename_is File.dirname(__FILE__) + "../firmware/dist/firmware.cof"
    end

A full list of the special RPicSim methods you can call inside your class definition can be found by looking at the documentation for {RPicSim::Sim::ClassDefinitionMethods}.

Required properties
----

There are two things you must do inside a simulation class.

First, call {RPicSim::Sim::ClassDefinitionMethods#device_is device_is} in order to specify the PIC device your firmware runs on.  Unfortunately, RPicSim cannot just detect this information from your COF file.  The argument to `device_is` should be a simple string containing the official name of the PIC device, like "PIC10F322".

Second, call {RPicSim::Sim::ClassDefinitionMethods#filename_is filename_is} to specify the path to your COF or HEX file.  This must be done after calling `device_is`.
In the example, we start with `File.dirname(__FILE__)`, which is the name of the directory that the current Ruby file is in, and add a string to that.
This allows us to move our tests and firmware files around on the disk without changing the `filename_is` line.

Pins
----

You can use {RPicSim::Sim::ClassDefinitionMethods#def_pin def_pin} to define an alternative name for a pin.  For more information, see {file:Pins.md}.


Variables
----

You can use {RPicSim::Sim::ClassDefinitionMethods#def_var def_var} to define a variable in RAM, program memory, or EEPROM.
For more information, see {file:Variables.md}.


Methods
----

It is sometimes helpful to define your own methods in the simulation class.  For example, here are some methods that help us simulate the effect of the user placing a jumper between RA1 and GND:

    class MySim < RPicSim::Sim
      device_is "PIC10F322"
      filename_is File.dirname(__FILE__) + "../firmware/dist/firmware.cof"
      
      def jumper_on
        pin(:RA1).set false
      end
      
      def jumper_off
        pin(:RA1).set true
      end
    end

By making these `jumper_on` and `jumper_off` methods, we can write lots of tests that manipulate the jumper but we don't have to constantly worry about how the hardware jumper is implemented when writing or reading those tests.
This makes our tests clearer to the reader and makes it easier to adapt them to change.

If you have an instance of the simulation class, you can call such a method in the usual way:

    sim.jumper_on

    
Using the simulation class
----

To start a new simulation, you can simply make a new instance of the simulation class.  For example:

    sim = MySim.new

However, if you are using RSpec and RPicSim's {file:RSpecIntegration.md RSpec Integration}, then you should not create a new instance yourself.
Instead, make a before hook that calls {RPicSim::RSpec::Helpers#start_sim start_sim}.
This will start the simulation for you and use it to make some other methods and features available in your examples.
After running {RPicSim::RSpec::Helpers#start_sim start_sim}, you will be able to access your simulation object using the method `sim`.

For example:

    describe "my firmware" do
      before do
        start_sim MySim
      end
      
      it "runs to the :abc label" do
        sim.run_to :abc, cycle_limit: 100
      end
    end
