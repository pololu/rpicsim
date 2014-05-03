require_relative '../spec_helper'

describe 'RPicSim::Sim#eeprom' do
  before do
    start_sim Firmware::EepromVariables
    reg(:EEADR).value = 0x10
  end

  it 'can be read by Ruby' do
    expect(eeprom.read_byte(0x10)).to eq 0x84
  end

  it 'can be written by Ruby' do
    eeprom.write_byte 0x10, 0x48
    expect(eeprom.read_byte(0x10)).to eq 0x48
  end

  it 'can be read by the firmware after being written by Ruby' do
    eeprom.write_byte 0x10, 0xAE
    run_subroutine :eepromRead, cycle_limit: 100
    expect(wreg.value).to eq 0xAE
  end

  it 'can be written by firmware' do
    wreg.value = 0xE2
    run_subroutine :eepromWrite, cycle_limit: 20_000
    expect(eeprom.read_byte(0x10)).to eq 0xE2
  end

end
