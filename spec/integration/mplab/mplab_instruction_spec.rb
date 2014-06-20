require_relative '../../spec_helper'

describe RPicSim::Mplab::MplabInstruction do
  # Some fields in PIC instructions are signed two's complement numbers,
  # but unfortunately MPLAB X does not give us the signed value.  We need
  # to get the signed value from the unsigned value.  That conversion is done
  # in the MplabInstruction class so that almost all the Ruby code will get
  # the correct values for the signed operands.
  #
  # PIC18:
  #   8-bit signed field named n:  BC, BN, BNC, BNN, BNOV, BNZ, BOV, BZ
  #   11-bit signed field named n: BRA, RCALL
  #
  # Enhanced midrange:
  #   9-bit signed field named k:  BRA
  describe 'fields that hold a signed value' do
    describe 'for PIC18 architecture' do
      instructions = [
        ['BC',     8],
        ['BN',     8],
        ['BNC',    8],
        ['BNN',    8],
        ['BNOV',   8],
        ['BNZ',    8],
        ['BOV',    8],
        ['BZ',     8],
        ['BRA',   11],
        ['RCALL', 11],
      ]

      before(:all) do
        filename = Firmware::Test18F25K50.filename
        device = Firmware::Test18F25K50.device
        @mplab_program_file = RPicSim::Mplab::MplabProgramFile.new(filename, device)
        @assembly = RPicSim::Mplab::MplabAssembly.new(device)
        @assembly.load_file(filename)
        @disassembler = @assembly.disassembler
      end

      let(:opcode) { rspec_example.metadata[:opcode] }
      let(:address) do
        @mplab_program_file.symbols_in_program_memory[('ins_' + opcode.downcase).to_sym]
      end

      def n_value(address)
        inst = @disassembler.disassemble(address)
        raise "wrong opcode #{inst.opcode}" if inst.opcode != opcode
        inst.operands[:n]
      end

      instructions.each do |opcode, bits|
        describe opcode, opcode: opcode do
          it 'can decode 0' do
            expect(n_value(address + 4)). to eq 0
          end

          it 'can decode the maximum value' do
            expect(n_value(address + 6)). to eq((1 << (bits - 1)) - 1)
          end

          it 'can decode the minimum value' do
            expect(n_value(address + 8)). to eq(-(1 << (bits - 1)))
          end
        end
      end

    end

    describe 'for enhanced midrange architecture' do
      before(:all) do
        filename = Firmware::Test16F1826.filename
        device = Firmware::Test16F1826.device
        @mplab_program_file = RPicSim::Mplab::MplabProgramFile.new(filename, device)
        @assembly = RPicSim::Mplab::MplabAssembly.new(device)
        @assembly.load_file(filename)
        @disassembler = @assembly.disassembler
      end

      def k_value(address)
        inst = @disassembler.disassemble(address)
        raise "wrong opcode #{inst.opcode}" if inst.opcode != opcode
        inst.operands[:k]
      end

      instructions = [
        ['BRA',    9],
        ['ADDFSR', 6],
      ]

      let(:opcode) { rspec_example.metadata[:opcode] }
      let(:address) do
        @mplab_program_file.symbols_in_program_memory[('ins_' + opcode.downcase).to_sym]
      end

      instructions.each do |opcode, bits|
        describe opcode, opcode: opcode do

          it 'can decode 0' do
            expect(k_value(address + 2)). to eq 0
          end

          it 'can decode the maximum value' do
            expect(k_value(address + 3)). to eq((1 << (bits - 1)) - 1)
          end

          it 'can decode the minimum value' do
            expect(k_value(address + 4)). to eq(-(1 << (bits - 1)))
          end

        end
      end

    end
  end

  describe 'unrecognized instruction for enhanced midrange devices', flaw: true do
    before(:all) do
      filename = Firmware::Test16F1826.filename
      device = Firmware::Test16F1826.device
      @mplab_program_file = RPicSim::Mplab::MplabProgramFile.new(filename, device)
      @assembly = RPicSim::Mplab::MplabAssembly.new(device)
      @assembly.load_file(filename)
      @disassembler = @assembly.disassembler
    end

    ['TRIS', 'OPTION'].each do |opcode|
      specify "does not recognize #{opcode}" do
        address = @mplab_program_file.symbols_in_program_memory[:ins_option]
        mplab_instruction = @disassembler.disassemble(address)
        expect(mplab_instruction).to eq :invalid
      end
    end

  end

end
