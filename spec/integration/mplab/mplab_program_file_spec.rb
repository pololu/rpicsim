require_relative '../../spec_helper'

describe RPicSim::Mplab::MplabProgramFile do
  let(:device) { 'PIC10F322' }
  let(:filename) { Firmware::NestedSubroutines.filename }
  subject(:mplab_program_file) { described_class.new(filename, device) }

  describe '#symbols_in_program_memory' do
    it 'returns the labels from the assembly source' do
      expect(mplab_program_file.symbols_in_program_memory).to eq(
        isr: 4, start: 32, start2: 36, foo: 64,
        goo: 65, hoo: 96, ioo: 128, joo: 256,
      )
    end
  end

  describe '#symbols_in_ram' do
    it 'returns the variables from the assembly source' do
      expect(mplab_program_file.symbols_in_ram).to eq(var1: 64, var2: 65)
    end
  end

  describe '#symbols' do
    it 'returns all the symbols' do
      h = { var1: 64, var2: 65, isr: 4, start: 32, start2: 36,
            foo: 64, goo: 65, hoo: 96, ioo: 128, joo: 256 }
      expect(mplab_program_file.symbols).to eq h
    end
  end

end
