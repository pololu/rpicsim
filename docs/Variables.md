Variables
====

RPicSim allows you to read and write from simulated variables stored in RAM or flash, which can be useful for {file:UnitTesting.md unit testing}.  Variables are represented as Ruby objects that are instances of a subclass of {RPicSim::Variable}.

To access a variable, RPicSim needs to know the name it will be called in your Ruby code, what data type it is (e.g. 16-bit unsigned integer), and its address in memory.
In most cases, RPicSim can deduce the address by looking at the symbol table in your COF file, so you will not need to
type the address.
However, RPicSim cannot deduce the data type of a variable, so any variables used need to be explicitly defined beforehand.

Defining a RAM variable
----

RAM variables that you want to access from Ruby must be defined in the {file:DefiningSimulationClass.md simulation class} using {RPicSim::Sim::ClassDefinitionMethods#def_var def_var}.  For example:

    !!!ruby
    class MySim < RPicSim::Sim
      #...

      def_var :counter, :u8

    end

The first argument to `def_var` specifies what to call the variable in Ruby code.  Using the example above, you could access the variable object by passing `:counter` as the argument to {RPicSim::Sim#var}:

    !!!ruby
    sim.var(:counter)

Each variable also has a "shortcut" method by the same name.  This means that you can access the variable like this:

    !!!ruby
    sim.counter

The shortcuts are also available in RSpec thanks to RPicsim's {file:RSpecIntegration.md RSpec integration}, so you can simply write `counter` in any of your RSpec examples:

    !!!ruby
    it "drives the main output high" do
      expect(counter.value).to eq 44
    end

The second argument to `def_var` specifies the data type of the variable.  This is required.  For the full list of allowed types, see {RPicSim::Sim::ClassDefinitionMethods#def_var}.

In the example above, RPicSim will look in your firmware's COF file for a RAM symbol named "counter" and it will use that as the address for the variable, so you do not need to specify the address yourself.

You can use the `symbol` option to specify what symbol in the symbol table marks the location of the variable.  For example:

    !!!ruby
    def_var :counter, :u8, symbol: :_counter

The example above shows how you could access a variable from a C compiler (which will generally be prefixed with an underscore) without having to type the underscore in your tests.
More generally, the `symbol` option allows you to call a variable one thing in your firmware and call it a different thing in your tests.

RPicSim will raise an exception if it cannot find the specified symbol in the symbol table.  To troubleshoot this, you might print the list of variables that RPicSim found:

    !!!ruby
    p sim.class.program_file.var_addresses.keys

You can use the `address` option to specify an arbitrary address instead of using the symbol table.  For example:

    !!!ruby
    def_var :counter, :u8, address: 0x63


Defining Flash variables
----

Flash (program space) variables work the same way as RAM variables except:

* They are defined with {RPicSim::Sim::ClassDefinitionMethods#def_flash_var def_flash_var}.
* The set of allowed data types for the second argument of `def_flash_var` is different, and you can see the documentation by clicking the link above.
* Flash variables cannot be accessed with {RPicSim::Sim#var}, but can be accessed with {RPicSim::Sim#flash_var}


Using a variable
----

Once you have defined a variable and accessed it using one of the methods above, you will have an instance of a subclass of {RPicSim::Variable}.  You can read and write the value of the variable using the `value` attribute:

    !!!ruby
    counter.value = 0x6A
    expect(counter.value).to eq 0x6A


Addition example
----

This section contains a simple example showing how to apply the information above and use {RPicSim::Variable} objects.

Here is a minimal MPASM assembly program for the PIC10F322 that does not actually do anything but it has a 16-bit addition subroutine:

    !!!plain
    #include p10F322.inc
    __config(0x3E06)
      udata
    x res 2
    y res 2
    z res 2
      code 0
    addition  ; 16-bit addition routine:  z = x + y
      movf    x, W
      addwf   y, W
      movwf   z
      movf    x + 1, W
      btfsc   STATUS, C
      addlw   1
      addwf   y + 1, W
      movwf   z + 1
      return
      end

In `spec/spec_helper.rb`, we make a simulation class that points to the compiled COF file and defines the variables:

    !!!ruby
    require 'rpicsim/spec_helper'

    class Addition < RPicSim::Sim
      device_is "PIC10F322"
      filename_is File.dirname(__FILE__) + "../firmware/dist/firmware.cof"
      def_var :x, :u16
      def_var :y, :u16
      def_var :z, :u16
    end

In `spec/addition_spec.rb`, we write a simple unit test that writes to `x` and `y`, runs the `addition` subroutine, and checks that the correct result is stored in `z`:

    !!!ruby
    require_relative 'spec_helper'

    describe "addition routine" do
      before do
        start_sim Addition
      end
    
      it "can add 70 + 22"
        x.value = 70
        y.value = 22
        run_subroutine :addition, cycle_limit: 100
        expect(z.value).to eq 92
      end
    end