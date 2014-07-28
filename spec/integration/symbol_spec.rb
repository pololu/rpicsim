require 'spec_helper'

describe 'XC8 symbol file integration' do
  let(:sim_class) { Firmware::TestXC8 }
  let(:program_file) { sim_class.program_file }

  describe '#import_symbols' do
    it 'is a method in Sim::ClassDefinitionMethods' do
      expect(sim_class).to respond_to :import_symbols
    end

    it 'picks up the RAM variables' do
      expect(program_file.symbols[:_varRamU8]).to be
      expect(program_file.symbols_in_ram[:_varRamU8]).to be
    end

    it 'picks up program memory variables' do
      expect(program_file.symbols[:_varCodeU16]).to be
      expect(program_file.symbols_in_program_memory[:_varCodeU16]).to be
    end
  end

  describe '.def_symbol' do
    it 'works for a symbol of unknown memory type' do
      expect(program_file.symbols[:lateDefinedUnknown]).to be 45
      expect(program_file.symbols_in_ram[:lateDefinedUnknown]).to be nil
    end

    it 'works for a symbol in RAM' do
      expect(program_file.symbols[:lateDefinedRam]).to be 46
      expect(program_file.symbols_in_ram[:lateDefinedRam]).to be 46
    end

    it 'has a good error message if you give a bad memory type' do
      msg = "Invalid memory type: foo."
      expect { sim_class.def_symbol :abc, 1, :foo }.to raise_error msg
      expect(program_file.symbols[:abc]).to be nil
    end
  end

  describe '#label' do
    it 'picks up program memory symbols defined with def_symbol' do
      expect(sim_class.labels[:lateDefinedCode]).to be
    end
  end

  describe '#address_description' do
    it 'uses program memory symbols defined with def_symbol' do
      desc = sim_class.program_file.address_description(47)
      expect(desc).to eq "0x002f = lateDefinedCode"
    end
  end

  # We can't really test EEPROM here because XC8 does not seem to support EEPROM
  # variables on the PIC18F25K50.
end
