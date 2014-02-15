require_relative '../spec_helper'

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

  context 'as a disassembler' do
    subject(:instruction) { program_file.instruction(0) }
    
    specify { instruction.should be_a RPicSim::Instruction }

    specify { instruction.address.should == 0 }

    specify { instruction.opcode.should == 'CLRF' }
    
    specify { instruction.operands.should == {'f' => 0x20} }
    
    specify { instruction.to_s.should == 'Instruction(0x0000 = setupNormalFlash, CLRF 0x20)' }
    
    specify { instruction.inspect.should == '#<RPicSim::Instruction:0x0000 = setupNormalFlash, CLRF 0x20>' }
  end

  it "crashes when you try to create it directly", flaw: true do
    # TODO: this might be a flaw in our Ruby code so we should investigate a bit
    # It also prints a bunch of junk to the standard output so we need to silence it.

    proc = Proc.new do
      PicSim.mute_stdout do
        # it's bizarre that I need this next line; the exact same line inside mute_stdout doesn't
        # seem to have an effect but this one does
        java.lang.System.setOut(java.io.PrintStream.new(NullOutputStream.new))

        PicSim::ProgramFile.new(Firmware::Dir + 'FlashVariables.asm', 'PIC10F322')
      end
    end

    expect(proc).to raise_error
  end

end

describe 'RPicSim disassembly' do
  let(:opcode) { example.metadata[:opcode] }
  let(:address) { @program_file.label('ins_' + opcode.downcase).address }
  
  let(:instruction0) { @program_file.instruction(address) }
  let(:instruction1) { @program_file.instruction(address + 1) }
  
  shared_examples_for 'instruction' do
    it 'has the right address' do
      expect(instruction0.address).to eq address
    end
      
    it 'has the right opcode' do
      expect(instruction0.opcode).to eq opcode
    end

    it 'has the right size' do
      # the PIC18 stores flash addresses in terms of bytes, not words
      expect(instruction0.size).to eq example.metadata.fetch(:size, 2)
    end
  end
  
  context 'for PIC18 architecture' do
    before(:all) do
      @program_file = RPicSim::ProgramFile.new(Firmware::Test18F25K50.filename, Firmware::Test18F25K50.device)
    end
    
    conditional_skips_fa = %w{ CPFSEQ }
    
    describe 'GOTO', opcode: 'GOTO', size: 4 do
      it_behaves_like 'instruction'
      
      it 'has a k operand with a word address in it' do
        # the assembly was "goto 2"
        expect(instruction0.operands).to eq('k' => 1)
      end
      
      it 'leads into the right instruction' do
        expect(instruction0.next_addresses).to eq [2]
      end
      
    end
    
    conditional_skips_fa.each do |name|
      specify name do
        address = @program_file.label('ins_' + name.downcase).address
        i0 = @program_file.instruction(address)
        expect(i0.address).to eq address
        expect(i0.opcode).to eq name
        expect(i0.operands).to eq('f' => 4, 'a' => 0)
        expect(i0.size).to eq 2
        expect(i0).to be_a_kind_of RPicSim::Instruction::ConditionalSkip
        expect(i0.next_addresses).to eq [address + 2, address + 4]
        
        i1 = @program_file.instruction(address + 2)
        expect(i1.opcode).to eq name
        expect(i1.operands).to eq('f' => 5, 'a' => 1)
      end
    end

  end

end
