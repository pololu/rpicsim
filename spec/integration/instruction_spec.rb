require_relative '../spec_helper'

# Information sources:
#  DS33014J - the MPASM/MPLINK/MPLIB manual
#  Midrange: http://ww1.microchip.com/downloads/en/DeviceDoc/41375A.pdf

# TODO: test support for the PIC18 extended instruction set

describe RPicSim::Instruction do
  subject(:instruction) { Firmware::FlashVariables.program_file.instruction(0) }
    
  specify { instruction.to_s.should == 'Instruction(0x0000 = setupNormalFlash, CLRF 0x20)' }
    
  specify { instruction.inspect.should == '#<RPicSim::Instruction:0x0000 = setupNormalFlash, CLRF 0x20>' }
end

def describe_instruction(opcode, metadata = {}, &proc)
  describe(opcode, {opcode: opcode}.merge(metadata), &proc)
end

describe 'Disassembly' do
  let(:opcode) { example.metadata[:opcode] }
  let(:label_name) { example.metadata[:label_name] || ('ins_' + opcode.downcase) }
  let(:address) { program_file.label(label_name).address }
  let(:address_increment) { example.metadata[:address_increment] }

  let(:instruction0) { program_file.instruction(address) }
  let(:instruction1) { program_file.instruction(address + instruction0.size) }

  shared_examples_for 'instruction' do |opts = {}|
    size = opts[:size] || metadata[:address_increment]

    it 'has the right address' do
      expect(instruction0.address).to eq address
    end

    it "has opcode #{metadata[:opcode]}" do
      expect(instruction0.opcode).to eq opcode
    end

    it "has size #{size}" do
      # the PIC18 stores flash addresses in terms of bytes, not words
      expect(instruction0.size).to eq size
    end
    
    it "is valid" do
      expect(instruction0).to be_valid
    end

  end
  
  ##### Shared examples to test our decoding of fields #####

  shared_examples_for 'instruction with no fields' do
    string = metadata[:opcode]
    it "has string '#{string}'" do
      expect(instruction0.string).to eq string
    end

    it 'has no fields' do
      expect(instruction0.operands).to be_empty
    end
  end
  
  shared_examples_for 'instruction with field f' do
    string = metadata[:opcode] + ' 0x4'
    it "has string '#{string}'" do
      expect(instruction0.string).to eq string
    end

    it 'can properly decode all fields' do
      expect(instruction0.operands).to eq(f: 4)
      expect(instruction1.operands).to eq(f: 5)
    end
  end
  
  shared_examples_for 'instruction with fields f and a' do
    string = metadata[:opcode] + ' 0x4, ACCESS'
    it "has string '#{string}'" do
      expect(instruction0.string).to eq string
    end

    it 'can properly decode all fields' do
      expect(instruction0.operands).to eq(f: 4, a: 0)
      expect(instruction1.operands).to eq(f: 5, a: 1)
    end
  end

  shared_examples_for 'instruction with fields f and d' do
    string = metadata[:opcode] + ' 0x4, F'
    it "has string '#{string}'" do
      expect(instruction0.string).to eq string
    end

    it 'can properly decode all fields' do
      expect(instruction0.operands).to eq(f: 4, d: 1)
      expect(instruction1.operands).to eq(f: 5, d: 0)
    end
  end
  
  shared_examples_for 'instruction with fields f, d, and a' do
    string = metadata[:opcode] + ' 0x4, F, ACCESS'
    it "has string '#{string}'" do
      expect(instruction0.string).to eq string
    end

    it 'can properly decode all fields' do
      expect(instruction0.operands).to eq(f: 4, d: 1, a: 0)
      expect(instruction1.operands).to eq(f: 5, d: 0, a: 1)
    end
  end
  
  shared_examples_for 'instruction with fields f and b' do
    # MPLAB X puts bit numbers in hex for baseline devices.
    pic18_string = metadata[:opcode] + ' 0x4, 6'
    baseline_string = metadata[:opcode] + ' 0x4, 0x6'
    it "has string '#{pic18_string}' or '#{baseline_string}'" do
      expect([pic18_string, baseline_string]).to include instruction0.string
    end

    it 'can properly decode all fields' do
      expect(instruction0.operands).to eq(f: 4, b: 6)
      expect(instruction1.operands).to eq(f: 5, b: 7)
    end
  end
  
  shared_examples_for 'instruction with fields f, b, and a' do
    string = metadata[:opcode] + ' 0x4, 6, ACCESS'
    it "has string '#{string}'" do
      expect(instruction0.string).to eq string
    end

    it 'can properly decode all fields' do
      expect(instruction0.operands).to eq(f: 4, b: 6, a: 0)
      expect(instruction1.operands).to eq(f: 5, b: 7, a: 1)
    end
  end

  shared_examples_for 'instruction with field k that is not a word address' do
    string = metadata[:opcode] + ' 0x9'
    it "has string '#{string}'" do
      expect(instruction0.string).to eq string
    end

    it 'can properly decode k field' do
      expect(instruction0.operands).to eq(k: 9)
    end
  end
  
  shared_examples_for 'instruction with field k that is a word address' do
    string = metadata[:opcode] + ' 0x2'
    it "has string '#{string}'" do
      expect(instruction0.string).to eq string
    end

    it 'has a k field with a word address in it' do
      expected_k = 2 / address_increment
      expect(instruction0.operands).to eq(k: expected_k)
    end
  end
  
  shared_examples_for 'instruction with field k that is a relative word address' do
    it "has the right string" do
      string = "#{opcode} 0x%X" % [ instruction0.address + address_increment * (instruction0.operands[:k] + 1) ]
      expect(instruction0.string).to eq string
    end

    it 'has a k field with a relative word address in it' do
      expect(instruction0.operands).to eq(k: 4)
      expect(instruction1.operands).to eq(k: -4)
    end
  end
  
  shared_examples_for 'instruction with field n' do
  
    it "has the right string" do
      string = "#{opcode} 0x%X" % [ instruction0.address + address_increment * (instruction0.operands[:n] + 1) ]
      expect(instruction0.string).to eq string
    end

    it 'has an n field with a relative word address in it' do
      expected_n = 0xC / example.metadata[:address_increment] - 1
      expect(instruction0.operands).to eq(n: expected_n)
      expect(instruction1.operands).to eq(n: -expected_n)
    end
  end
  
  shared_examples_for 'instruction with fields n and k' do
    string = "#{metadata[:opcode]} 0, 9"
    it "has the string #{string}" do
      expect(instruction0.string).to eq string
    end
    
    it 'decodes all fields properly' do
      expect(instruction0.operands).to eq({n: 0, k: 9})
      expect(instruction1.operands).to eq({n: 1, k: -9})
    end
  end
  
  shared_examples_for 'instruction with field s' do
    string = "#{metadata[:opcode]} 0"
    it "has the string '#{string}'" do
      expect(instruction0.string).to eq string
    end

    it 'decodes all fields properly' do
      expect(instruction0.operands).to eq(s: 0)
      expect(instruction1.operands).to eq(s: 1)
    end
  end
  
  shared_examples_for 'instruction with field f with a very limited range' do
    string = "#{metadata[:opcode]} 0x5"
    it "has the string '#{string}'" do
      expect(instruction0.string).to eq string
    end

    it 'decodes all fields properly' do
      expect(instruction0.operands).to eq(f: 5)
      expect(instruction1.operands).to eq(f: 7)
    end
    
  end
  
  shared_examples_for 'instruction with fields k and s' do
    string = "#{metadata[:opcode]} 0x4, 0"
    it "has the string '#{string}'" do
      expect(instruction0.string).to eq string
    end

    it 'has the right operands' do
      expect(instruction0.operands).to eq(k: 2, s: 0)
      expect(instruction1.operands).to eq(k: 3, s: 1)
    end
  end
  
  shared_examples_for 'instruction with fields f and k' do
    string = "#{metadata[:opcode]} 0, 0x18"
    it "has the string '#{string}'" do
      expect(instruction0.string).to eq string
    end

    it 'decodes all fields properly' do
      expect(instruction0.operands).to eq(f: 0, k: 0x18)
      expect(instruction1.operands).to eq(f: 2, k: 0x19)
    end
  end
  
  shared_examples_for 'instruction with fields fs and fd' do
    string = "#{metadata[:opcode]} 0x6, 0x7"
    it "has string '#{string}'" do
      expect(instruction0.string).to eq string
    end

    it 'can properly decode all fields' do
      expect(instruction0.operands).to eq(:fs => 6, :fd => 7)
    end
  end
  
  shared_examples_for 'instruction with the MOVIW/MOVWI fields' do
    string = "#{metadata[:opcode]} ++FSR1"
    it "has string '#{string}'" do
      expect(instruction0.string).to eq string
    end
    
    it 'can properly decode all fields' do
      expect(instruction0.operands).to eq({n: 1, m: 0})  # ++FSR1
      expect(instruction1.operands).to eq({n: 0, k: 2})  # 2[FSR0]
    end
  end

  
  ##### Shared examples to test our knowledge of control flow.  ######
  
  shared_examples_for 'instruction that does not affect control' do
    it 'leads to the instruction after it' do
      expect(instruction0.next_addresses).to eq [address + instruction0.size]
    end
  end
  
  shared_examples_for 'instruction that ends control' do
    it 'leads to no instructions' do
      expect(instruction0.next_addresses).to be_empty    
    end
  end
  
  shared_examples_for 'instruction with hard-to-predict effect on control' do
     it 'leads to no instructions' do
       expect(instruction0.next_addresses).to be_empty
     end
  end

  shared_examples_for 'conditional skip' do
    it 'leads to the next two instructions after it' do
      expect(instruction0.next_addresses).to eq [
        address + instruction0.size,
        address + address_increment * 2
      ]
    end
  end

  shared_examples_for 'conditional relative branch' do
    it 'leads to the next instruction and to the branch target' do
      expect(instruction0.next_addresses).to eq [
        address + address_increment * (instruction0.operands[:n] + 1),
        address + instruction0.size,
      ]
    end
    
    specify 'neither transition has an affect on call stack depth' do
      expect(instruction0.transitions.map(&:call_depth_change)).to eq [0, 0]
    end
  end
  
  shared_examples_for 'call' do
    it 'leads to the next instruction and to the call' do
      expect(instruction0.next_addresses).to eq [
        address_increment * instruction0.operands[:k],
        address + instruction0.size,
      ]
    end
    
    specify 'the first transition counts as a call' do
      expect(instruction0.transitions.map(&:call_depth_change)).to eq [1, 0]
    end
  end
  
  shared_examples_for 'goto' do
    it 'leads to the instruction specified by k' do
      expect(instruction0.next_addresses).to eq [instruction0.operands[:k] * address_increment]
    end  
  end

  shared_examples_for 'relative call' do
    it 'leads to the next instruction and to the call' do
      expect(instruction0.next_addresses).to eq [
        address + address_increment * (instruction0.operands[:n] + 1),
        address + instruction0.size,
      ]
    end
    
    specify 'the first transition counts as a call' do
      expect(instruction0.transitions.map(&:call_depth_change)).to eq [1, 0]
    end
  end
  
  shared_examples_for 'relative branch' do |field_name|
    it 'leads to the branch target' do
      expect(instruction0.next_addresses).to eq [
        address + address_increment * (instruction0.operands[field_name] + 1),
      ]
    end
    
    specify 'the transition does not count as a call' do
      expect(instruction0.transitions.map(&:call_depth_change)).to eq [0]
    end
  end
  
  
  context 'for baseline architecture', address_increment: 1 do
    let(:program_file) { Firmware::Test10F202.program_file }
    
    describe 'byte-oriented operations' do
      describe_instruction 'ADDWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'ANDWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'CLRF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field f'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'CLRW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'COMF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'DECF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'DECFSZ' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'conditional skip'
      end
      
      describe_instruction 'INCF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'INCFSZ' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'conditional skip'
      end
      
      describe_instruction 'IORWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'MOVF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'MOVWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field f'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'NOP' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'RLF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'RRF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'SUBWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'SWAPF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'XORWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
    end

    describe 'bit-oriented operations' do
      describe_instruction 'BCF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and b'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'BSF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and b'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'BTFSC' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and b'
        it_behaves_like 'conditional skip'
      end

      describe_instruction 'BTFSS' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and b'
        it_behaves_like 'conditional skip'
      end
    end
    
    describe 'literal and control operations' do
    
      describe_instruction 'ANDLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'CALL' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is a word address'
        it_behaves_like 'call'
      end
      
      describe_instruction 'CLRWDT' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'GOTO' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is a word address'
        it_behaves_like 'goto'
      end

      describe_instruction 'IORLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'MOVLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'OPTION' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'RETLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that ends control'
      end

      describe_instruction 'SLEEP' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'TRIS' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field f with a very limited range'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'XORLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end
    end

  end
  
  context 'for midrange architecture', address_increment: 1 do
    let(:program_file) { Firmware::Test10F322.program_file }
    
    describe 'byte-oriented operations' do
      describe_instruction 'ADDWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'ANDWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'CLRF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field f'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'CLRW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'COMF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'DECF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'DECFSZ' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'conditional skip'
      end
      
      describe_instruction 'INCF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'INCFSZ' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'conditional skip'
      end
      
      describe_instruction 'IORWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'MOVF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'MOVWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field f'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'NOP' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'RLF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'RRF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'SUBWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'SWAPF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'XORWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
    end

    describe 'bit-oriented operations' do
      describe_instruction 'BCF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and b'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'BSF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and b'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'BTFSC' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and b'
        it_behaves_like 'conditional skip'
      end

      describe_instruction 'BTFSS' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and b'
        it_behaves_like 'conditional skip'
      end
    end
    
    describe 'literal and control operations' do
    
      describe_instruction 'ADDLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'ANDLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'CALL' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is a word address'
        it_behaves_like 'call'
      end
      
      describe_instruction 'CLRWDT' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'GOTO' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is a word address'
        it_behaves_like 'goto'
      end

      describe_instruction 'IORLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'MOVLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'RETFIE' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that ends control'
      end

      describe_instruction 'RETLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that ends control'
      end

      describe_instruction 'SLEEP' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'SUBLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'XORLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end
    end

  end
  
  context 'for enhanced midrange architecture', address_increment: 1 do
    let(:program_file) { Firmware::Test16F1826.program_file }
    
    describe 'byte-oriented operations' do
      describe_instruction 'ADDWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'ADDWFC' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'ANDWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'ASRF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'CLRF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field f'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'CLRW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'COMF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'DECF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'INCF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'IORWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'LSLF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'LSRF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'MOVF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'MOVWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field f'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'RLF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'RRF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'SUBWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'SUBWFB' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'SWAPF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'XORWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'instruction that does not affect control'
      end
    end
    
    describe 'byte-oriented skip operations' do
      describe_instruction 'DECFSZ' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'conditional skip'
      end
      
      describe_instruction 'INCFSZ' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and d'
        it_behaves_like 'conditional skip'
      end
    end

    describe 'bit-oriented operations' do
      describe_instruction 'BCF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and b'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'BSF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and b'
        it_behaves_like 'instruction that does not affect control'
      end
    end
    
    describe 'bit-oriented skip operations' do
      describe_instruction 'BTFSC' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and b'
        it_behaves_like 'conditional skip'
      end

      describe_instruction 'BTFSS' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and b'
        it_behaves_like 'conditional skip'
      end
    end
    
    describe 'literaloperations' do
    
      describe_instruction 'ADDLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'ANDLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'IORLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'MOVLB' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'MOVLP' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'MOVLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'SUBLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'XORLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end
    end

    describe 'control operations' do
      describe_instruction 'BRA' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is a relative word address'
        it_behaves_like 'relative branch', :k
      end
      
      describe_instruction 'BRW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction with hard-to-predict effect on control'
      end
    
      describe_instruction 'CALL' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is a word address'
        it_behaves_like 'call'
      end
      
      describe_instruction 'CALLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction with hard-to-predict effect on control'
      end
      
      describe_instruction 'GOTO' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is a word address'
        it_behaves_like 'goto'
      end

      describe_instruction 'RETFIE' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that ends control'
      end

      describe_instruction 'RETLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that ends control'
      end

      describe_instruction 'RETURN' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that ends control'
      end
    end
    
    describe 'inherent oeprations' do
      describe_instruction 'CLRWDT' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'NOP' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end
      
      # OPTION cannot be handled by the MPLAB X disassembler.
      
      describe_instruction 'RESET' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that ends control'
      end

      describe_instruction 'SLEEP' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      # TRIS cannot be handled by the MPLAB X disassembler.
      
    end
    
    describe 'C-compiler optimized' do
      describe_instruction 'ADDFSR' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields n and k'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'MOVIW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with the MOVIW/MOVWI fields'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'MOVWI' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with the MOVIW/MOVWI fields'
        it_behaves_like 'instruction that does not affect control'
      end
    end
  end
  
  context 'for PIC18 architecture', address_increment: 2 do
    let(:program_file) { Firmware::Test18F25K50.program_file }

    describe 'byte-oriented operations' do

      describe_instruction 'ADDWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'ADDWFC' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'ANDWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'CLRF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'COMF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'CPFSEQ' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and a'
        it_behaves_like 'conditional skip'
      end

      describe_instruction 'CPFSGT' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and a'
        it_behaves_like 'conditional skip'
      end

      describe_instruction 'CPFSLT' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and a'
        it_behaves_like 'conditional skip'
      end

      describe_instruction 'DECF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'DECFSZ' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'conditional skip'
      end

      describe_instruction 'INCF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'INCFSZ' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'conditional skip'
      end

      describe_instruction 'INFSNZ' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'conditional skip'
      end

      describe_instruction 'IORWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'MOVF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'MOVFF' do
        it_behaves_like 'instruction', size: 4
        it_behaves_like 'instruction with fields fs and fd'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'MOVWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'MULWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'NEGF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'RLCF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'RLNCF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'RRCF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'RRNCF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'SETF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and a'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'SUBWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'SUBWFB' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'SWAPF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'TSTFSZ' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f and a'
        it_behaves_like 'conditional skip'
      end

      describe_instruction 'XORWF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, d, and a'
        it_behaves_like 'instruction that does not affect control'
      end

    end

    describe 'bit-oriented operations' do
      describe_instruction 'BCF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, b, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'BSF' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, b, and a'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'BTFSC' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, b, and a'
        it_behaves_like 'conditional skip'
      end

      describe_instruction 'BTFSS' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, b, and a'
        it_behaves_like 'conditional skip'
      end

      describe_instruction 'BTG' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with fields f, b, and a'
        it_behaves_like 'instruction that does not affect control'
      end
    end
        
    describe 'control operations' do

      describe_instruction 'BC' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field n'
        it_behaves_like 'conditional relative branch'
      end

      describe_instruction 'BN' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field n'
        it_behaves_like 'conditional relative branch'
      end
      
      describe_instruction 'BNC' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field n'
        it_behaves_like 'conditional relative branch'
      end

      describe_instruction 'BNN' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field n'
        it_behaves_like 'conditional relative branch'
      end

      describe_instruction 'BNOV' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field n'
        it_behaves_like 'conditional relative branch'
      end
      
      describe_instruction 'BNZ' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field n'
        it_behaves_like 'conditional relative branch'
      end

      describe_instruction 'BRA' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field n'
        it_behaves_like 'relative branch', :n
      end
      
      describe_instruction 'BZ' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field n'
        it_behaves_like 'conditional relative branch'
      end
      
      describe_instruction 'CALL' do
        it_behaves_like 'instruction', size: 4
        it_behaves_like 'instruction with fields k and s'
        it_behaves_like 'call'
      end
      
      describe_instruction 'CLRWDT' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'DAW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'GOTO' do
        it_behaves_like 'instruction', size: 4
        it_behaves_like 'instruction with field k that is a word address'
        it_behaves_like 'goto'
      end

      describe_instruction 'NOP' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'POP' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        # Technically PUSH and POP do affect control but we have not implemented that yet.
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'PUSH' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        # Technically PUSH and POP do affect control but we have not implemented that yet.
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'RCALL' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field n'
        it_behaves_like 'relative call'
      end
      
      describe_instruction 'RESET' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that ends control'
      end
      
      describe_instruction 'RETFIE' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field s'
        it_behaves_like 'instruction that ends control'        
      end
      
      # NOTE: In some documents from Microchip this is categorized as a control
      # operation and in others it is a literal operation, or both.
      describe_instruction 'RETLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that ends control'
      end

      describe_instruction 'RETURN' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field s'
        it_behaves_like 'instruction that ends control'        
      end
      
      describe_instruction 'SLEEP' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end
      
    end
    
    describe 'literal operaions' do
    
      describe_instruction 'ADDLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'ANDLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'IORLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'LFSR' do
        it_behaves_like 'instruction', size: 4
        it_behaves_like 'instruction with fields f and k'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'MOVLB' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'MOVLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'MULLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'SUBLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'XORLW' do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with field k that is not a word address'
        it_behaves_like 'instruction that does not affect control'
      end
      
    end
    
    describe 'program memory operations' do
    
      describe_instruction 'TBLRD*', label_name: :ins_tblrd do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'TBLRD*+', label_name: :ins_tblrd_postinc do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'TBLRD*-', label_name: :ins_tblrd_postdec do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'TBLRD+*', label_name: :ins_tblrd_preinc do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'TBLWT*', label_name: :ins_tblwt do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end
      
      describe_instruction 'TBLWT*+', label_name: :ins_tblwt_postinc do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'TBLWT*-', label_name: :ins_tblwt_postdec do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

      describe_instruction 'TBLWT+*', label_name: :ins_tblwt_preinc do
        it_behaves_like 'instruction'
        it_behaves_like 'instruction with no fields'
        it_behaves_like 'instruction that does not affect control'
      end

    end
    
  end

end


describe 'Disassembly of invalid instructions' do
  let(:program_file) { Firmware::Test18F25K50.program_file }
  let(:address) { program_file.label(:invalidInstruction).address }
  subject(:instruction) { program_file.instruction(address)}
  
  it 'is invalid' do
    expect(instruction).to_not be_valid
  end
  
  it 'has a size equal to the address increment' do
    expect(instruction.size).to eq 2
  end
  
  it 'has a string of [INVALID]' do
    expect(instruction.string).to eq '[INVALID]'
  end
  
  it 'has the right address' do
    expect(instruction.address).to eq address
  end
  
  it 'has a transition to the next instruction' do
    # because that is most likely what the PIC will do
    expect(instruction.next_addresses).to eq [address + 2]
  end
end