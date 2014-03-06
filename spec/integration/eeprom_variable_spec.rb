require_relative '../spec_helper'

describe 'EEPROM variables' do
  before do
    start_sim Firmware::EepromVariables
  end

  context 'unsigned 8-bit' do
    it 'has the right address' do
      expect(eepromVar1.address).to eq 0x10
    end

    it 'can be read by Ruby' do
      expect(eepromVar1.value).to eq 0x84
    end

    it 'can be written by Ruby' do
      eepromVar1.value = 200
      expect(eepromVar1.value).to eq 200
    end

    it 'can be read by the firmware after being written by Ruby' do
      reg(:EEADR).value = eepromVar1.address
      eepromVar1.value = 0x01
      run_subroutine :eepromRead, cycle_limit: 100
      expect(wreg.value).to eq 0x01
    end
  end
end