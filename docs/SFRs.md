SFRs
====

The Special Function Registers (SFRs) on a microcontroller enable the firmware to interact with the microcontroller's peripherals and talk to the outside world.
RPicSim supports reading and writing these SFRs from Ruby.
This can be useful if you want to put your PIC into a particular state and see how a part of your firmware responds.
Each SFR is represented as an instance of the {RPicSim::Register} class.


Getting a Register object
----

The {RPicSim::Sim#sfr} method can be called on your simulation object to retrieve a {RPicSim::Register} object:

    !!!ruby
    sim.sfr(:LATA)  # => returns a Register object

If you are using RPicSim's {file:RSpecIntegration.md RSpec integration}, the `sfr` method inside an example automatically redirects to the `@sim` object:

    !!!ruby
    it "works" do
      sfr(:LATA)  # => returns a Register object
    end

The first argument of {RPicSim::Sim#sfr} should be a symbol containing the name of the SFR.
The name comes from the MPLAB X code, but it should match the name given in the microcontroller's datasheet.


Using a register
----

Once you have obtained the {RPicSim::Register Register} object using one of the methods above, you can read and write the value of the SFR using the `value` attribute:

    !!!ruby
    sfr(:LATA).value = 0x7B
    expect(sfr(:LATA).value).to eq 0x7B


Protected bits
----

When you write to the register with {RPicSim::Register#value=}, you are probably writing to it in the same way that the simulated microcontroller would write to it.
This means that some bits might not be writable or might have restrictions on what value can be written to them.
For example, the TO and PD bits of the STATUS register on the PIC10F322 are not writable by the microcontroller.

To get around this, you can use {RPicSim::Register#memory_value=} instead, which should allow you to write to any of the bits.


Peripheral updating
----

The MPLAB X code contains various objects that simulate the peripherals on a chip, such as the ADC.
It has not been determined whether writing to SFRs using the {RPicSim::Register} object updates the simulation of those peripherals in the proper way.
Also, whether the peripherals get updated might depend on whether the `value` or the `memory_value` attribute is used for writing.


Non-memory-mapped registers
----

The MPLAB X code considers "SFRs" to only be the special registers that have an address in memory.
The special registers without a memory address are called Non-Memory-Mapped Registers (NMMRs).
To access these registers, you can use {RPicSim::Sim#nmmr} which is similar to {RPicSim::Sim#sfr}.

On some chips, WREG and STKPTR are SFRs and on other chips they are NMMRs.  To make it easier to access these two registers, RPicSim provides the methods {RPicSim::Sim#wreg} and {RPicSim::Sim#stkptr}.  Those methods can be called directly in RSpec examples thanks to RPicSim's {file:RSpecIntegration.md RSpec integration}:

    !!!ruby
    it "sets W to 5" do
      expect(wreg.value).to eq 5
    end

To access other registers without worrying about what type they are, you can use {RPicSim::Sim#sfr_or_nmmr}.
