require 'spec_helper'

describe 'XC8 symbol file integration' do
  let(:sim_class) { Firmware::TestXC8 }

  it 'picks up the RAM variables' do
    expect(sim_class.symbols[:_varRamU8]).to be
    expect(sim_class.symbols_in_ram[:_varRamU8]).to be
  end

  it 'picks up program memory variables' do
    expect(sim_class.symbols[:_varCodeU16]).to be
    expect(sim_class.symbols_in_program_memory[:_varCodeU16]).to be
  end

  # We can't really test EEPROM here because XC8 does not seem to support EEPROM
  # variables on the PIC18F25K50.
end
