Defining your simulation class
====

In order to run a simulation of your firmware using RPicSim, you must make a new subclass of {RPicSim::Pic}.  This class is called your _simulation class_. Below is an example:

    class MySim < RPicSim::Pic
      device_is "PIC10F322"
      filename_is File.dirname(__FILE__) + "../firmware/dist/firmware.cof"
    end

A full list of the special RPicSim methods you can call inside your class definition can be found by looking at the documentation for {RPicSim::Pic::ClassDefinitionMethods}.

Required properties
----

There are two things you must do inside a simulation class.

First, you need to call {RPicSim::Pic::ClassDefinitionMethods#device_is device_is} in order to specify the model of the PIC your firmware runs on.  Unfortunately, RPicSim cannot just detect this information from your COF file.  The argument to `device_is` should be a simple string containing the official name of the PIC, like "PIC10F322".

Secondly, you must call {RPicSim::Pic::ClassDefinitionMethods#filename_is filename_is} to specify the path to your COF or HEX file.  This must be done after calling `device_is`.
The recommended way to specify the path is to start with `File.dirname(__FILE__)`, which is the name of the directory that the current Ruby file is in, and add a string to that.
By doing it this way, you are making the fairly safe assumption that the relative path between the Ruby file and the firmware being tested will stay the same, but you are making no assumptions about the current working directory of the Ruby process or the absolute location of the firmware.


Pins
----

You can use {RPicSim::Pic::ClassDefinitionMethods#def_pin def_pin} to define an alternative name for a PIC pin.  For more information, see {file:Pins.md}.


Variables
----

You can use {RPicSim::Pic::ClassDefinitionMethods#def_var def_var} to define a variable in RAM, and {RPicSim::Pic::ClassDefinitionMethods#def_flash_var def_flash_var} to define a variable in flash.  For more information, see {file:Variables.md}.


Methods
----

It is sometimes helpful to define your own methods in the simulation class.  For example, here are some methods that help us simulate the effect of the user placing a jumper between RA1 and GND:

    class MySim < RPicSim::Pic
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

    pic.jumper_on

    
Using the simulation class
----

To start a new simulation, simply make a new instance of the simulation class.  For example:

    pic = MySim.new

However, if you are using RSpec and RPicSim's {file:RSpecIntegration.md RSpec Integration}, then you should not create a new instance yourself.  The recommended way to start the simulation is to make a before hook that calls {RPicSim::RSpec::Helpers#start_sim start_sim}.  The `start_sim` method will start the simulation for you and you can access the simulation in your RSpec examples by typing `pic`.  For example:

    describe "my firmware" do
      before do
        start_sim MySim
      end
      
      it "runs to the :abc label" do
        pic.run_to :abc, cycle_limit: 100
      end
    end
