Variables
====

RPicSim uses the {RPicSim::Variable} class to let you access simulated program variables stored in RAM, program memory, or EEPROM, as well as Special Function Registers, which can be useful for {file:UnitTesting.md unit testing}.

To access a variable, RPicSim needs to know the name it will be called in your Ruby code, what type of memory it is stored in, what data type it is (e.g. 16-bit unsigned integer), and its address in memory.
This information is deduced in different ways for the different types of variables described below.

User-defined variables
----
For variables defined in your firmware, RPicSim can usually deduce the address by looking at the symbol table in your COF file, so you will not need to type the address.
However, RPicSim cannot deduce the data type of a variable, so any variables used need to be explicitly defined in the {file:DefiningSimulationClass.md simulation class} using {RPicSim::Sim::ClassDefinitionMethods#def_var def_var}.
For example:

    !!!ruby
    class MySim < RPicSim::Sim
      #...

      def_var :counter, :uint8

    end

The first argument to `def_var` specifies what to call the variable in Ruby code.  Using the example above, you could access the variable object by passing `:counter` as the argument to {RPicSim::Sim#var}:

    !!!ruby
    sim.var(:counter)

Each variable also has a method on the simulation object by the same name.
This means that you can access the variable like this:

    !!!ruby
    sim.counter

A shortcut is also available in RSpec thanks to RPicsim's {file:RSpecIntegration.md RSpec integration}, so you can simply write `counter` in any of your RSpec examples:

    !!!ruby
    it "drives the main output high" do
      expect(counter.value).to eq 44
    end

The second argument to `def_var` specifies the data type of the variable.  This is required.  For the full list of allowed types, see {RPicSim::Sim::ClassDefinitionMethods#def_var}.

In the example above, RPicSim will look in your firmware's COF file for a RAM symbol named "counter" and it will use that as the address for the variable, so you do not need to specify the address yourself.

You can use the `symbol` option to specify what symbol in the symbol table marks the location of the variable.  For example:

    !!!ruby
    def_var :counter, :uint8, symbol: :_counter

The example above shows how you could access a variable from a C compiler (which will generally be prefixed with an underscore) without having to type the underscore in your tests.
More generally, the `symbol` option allows you to call a variable one thing in your firmware and call it a different thing in your tests.

RPicSim will raise an exception if it cannot find the specified symbol in the symbol table.  To troubleshoot this, you might print the list of symbols that RPicSim found:

    !!!ruby
    p sim.class.program_file.var_addresses.keys

You can use the `address` option to specify an arbitrary address instead of using the symbol table.  For example:

    !!!ruby
    def_var :counter, :uint8, address: 0x63
    
Variables are assumed to be in RAM by default, but you can specify that they are in program memory or EEPROM using the `memory` option.

    !!!ruby
    def_var :settings, :word, memory: :program_memory
    def_var :checksum, :uint16, memory: :eeprom

### Program memory on non-PIC18 devices

On non-PIC18 devices, program memory is made up of words that are 12 bits or 14 bits wide.

The type of address used for program memory of these devices is called a _word address_ because it specifies the number of a word instead of the number of a byte.  For example, a word address of `1` would correspond to the second word in program memory.

To access all the bits of a particular word, you can define your variable to be of the +:word+ type as shown in the example above.
If you specify any of the integer types like :uint8 or :int16, the bytes that comprise that variable will live in the least-significant 8 bits of one or more words in program memory.
The upper bits of the words will not be changed when writing to the variable.

This behavior is useful because if you store an integer in program memory as 1 to 4 consecutive RETLW instructions, you can read and write from it in Ruby without changing the bits that make those words be RETLW instructions.


Accessing special function registers
----

The Special Function Registers (SFRs) on a microcontroller enable the firmware to interact with the microcontroller's peripherals and talk to the outside world.
The {RPicSim::Sim#reg} method can be called on your simulation object to retrieve a {RPicSim::Variable} object:

    !!!ruby
    sim.reg(:LATA)  # => returns a Variable object

If you are using RPicSim's {file:RSpecIntegration.md RSpec integration}, the `reg` method inside an example automatically redirects to the `@sim` object:

    !!!ruby
    it "works" do
      reg(:LATA)  # => returns a Variable object
    end

The first argument of {RPicSim::Sim#reg} should be a symbol containing the name of the SFR.
The name comes from the MPLAB X code, but we expect it to match the name given in the microcontroller's datasheet.

Note that the MPLAB X code considers "SFRs" to only be the special registers that have an address in memory.
The special registers without a memory address are called Non-Memory-Mapped Registers (NMMRs).
For example, on some chips, WREG and STKPTR are NMMRs.
You can access NMMRs in exactly the same way as SFRs:

    !!!ruby
    it "sets W to 5" do
      expect(reg(:WREG).value).to eq 5
    end


Using a variable
----

Once you have defined a variable and accessed it using one of the methods above, you will have an instance of a subclass of {RPicSim::Variable}.  You can read and write the value of the variable using the `value` attribute:

    !!!ruby
    counter.value = 0x6A
    expect(counter.value).to eq 0x6A


Protected bits
----

When you write to a register with {RPicSim::Variable#value=}, you are (according to our understanding of MPLAB X) writing to it in the same way that the simulated microcontroller would write to it.
This means that some bits might not be writable or might have restrictions on what value can be written to them.
For example, the TO and PD bits of the STATUS register on the PIC10F322 are not writable by the microcontroller.

To get around this, you can use {RPicSim::Variable#memory_value=} instead, which should allow you to write to any of the bits.


Peripheral updating
----

The MPLAB X code contains various objects that simulate the peripherals on a chip, such as the ADC.
We have not determined whether writing to SFRs using the {RPicSim::Variable} object updates the simulation of those peripherals in the proper way.
Also, whether the peripherals get updated might depend on whether the `value` or the `memory_value` attribute is used for writing.


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
    require 'rpicsim/rspec'

    class Addition < RPicSim::Sim
      device_is "PIC10F322"
      filename_is File.dirname(__FILE__) + "../firmware/dist/firmware.cof"
      def_var :x, :uint16
      def_var :y, :uint16
      def_var :z, :uint16
    end

In `spec/addition_spec.rb`, we write a simple unit test that writes to `x` and `y`, runs the `addition` subroutine, and checks that the correct result is stored in `z`:

    !!!ruby
    require_relative 'spec_helper'

    describe "addition routine" do
      before do
        start_sim Addition
      end
    
      it "can add 70 + 22" do
        x.value = 70
        y.value = 22
        run_subroutine :addition, cycle_limit: 100
        expect(z.value).to eq 92
      end
    end