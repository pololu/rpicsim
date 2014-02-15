require_relative '../spec_helper'

describe RPicSim::Instruction do
  context 'as a disassembler' do
    subject(:instruction) { Firmware::FlashVariables.program_file.instruction(0) }
    
    specify { instruction.should be_a described_class }

    specify { instruction.address.should == 0 }

    specify { instruction.opcode.should == 'CLRF' }
    
    specify { instruction.operands.should == {:f => 0x20} }
    
    specify { instruction.to_s.should == 'Instruction(0x0000 = setupNormalFlash, CLRF 0x20)' }
    
    specify { instruction.inspect.should == '#<RPicSim::Instruction:0x0000 = setupNormalFlash, CLRF 0x20>' }
  end
end