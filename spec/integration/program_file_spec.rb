require 'spec_helper'

describe RPicSim::ProgramFile do
  subject(:program_file) do
    Firmware::FlashVariables.program_file
  end

  describe "#address_description works" do
    specify { subject.address_description(0x0000).should == "0x0000 = setupNormalFlash" }
    specify { subject.address_description(0x0001).should == "0x0001 = setupNormalFlash+0x1" }
    specify { subject.address_description(0x0006).should == "0x0006 = setupUserId0+0x1" }
    specify { subject.address_description(-1).should == "-1" }
  end

  it "acts as a disassembler" do
    instruction = program_file.instruction(0)
    instruction.should be_a RPicSim::Instruction
    instruction.address.should == 0
    instruction.opcode.should == "CLRF"
    instruction.operands.should == {"f" => 0x20}
  end

  it "crashes when you try to create it directly", flaw: true do
    # TODO: this might be a flaw in our Ruby code so we should investigate a bit
    # It also prints a bunch of junk to the standard output so we need to silence it.

    proc = Proc.new do
      PicSim.mute_stdout do
        # it's bizarre that I need this next line; the exact same line inside mute_stdout doesn't
        # seem to have an effect but this one does
        java.lang.System.setOut(java.io.PrintStream.new(NullOutputStream.new))

        PicSim::ProgramFile.new(Firmware::Dir + "FlashVariables.asm", "PIC10F322")
      end
    end

    expect(proc).to raise_error
  end

end