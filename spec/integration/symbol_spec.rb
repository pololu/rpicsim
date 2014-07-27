require 'spec_helper'

describe 'XC8 symbol file integration' do
  let(:sim_class) { Firmware::TestXC8 }

  describe '#use_symbols' do
    it 'is a method in Sim::ClassDefinitionMethods' do
      expect(sim_class).to respond_to :use_symbols
    end

    it 'picks up the RAM variables' do
      expect(sim_class.symbols[:_varRamU8]).to be
      expect(sim_class.symbols_in_ram[:_varRamU8]).to be
    end

    it 'picks up program memory variables' do
      expect(sim_class.symbols[:_varCodeU16]).to be
      expect(sim_class.symbols_in_program_memory[:_varCodeU16]).to be
    end
  end

  describe '.def_symbol' do
    it 'works for a symbol of unknown memory type' do
      expect(sim_class.symbols[:postDefinedUnknown]).to be 45
      expect(sim_class.symbols_in_ram[:postDefinedUnknown]).to be nil
    end

    it 'works for a symbol in RAM' do
      expect(sim_class.symbols[:postDefinedRam]).to be 46
      expect(sim_class.symbols_in_ram[:postDefinedRam]).to be 46
    end

    it 'has a good error message if you give a bad memory type' do
      msg = "Invalid memory type: foo."
      expect { sim_class.def_symbol :abc, 1, :foo }.to raise_error msg
      expect(sim_class.symbols[:abc]).to be nil
    end
  end

  # We can't really test EEPROM here because XC8 does not seem to support EEPROM
  # variables on the PIC18F25K50.
end
