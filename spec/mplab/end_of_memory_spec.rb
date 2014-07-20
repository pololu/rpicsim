# MPLABX generally doesn't let us access the last byte/word of memory.

require 'spec_helper'

describe 'PIC18 end-of-memory issues' do
  before do
    start_sim Firmware::Test18F25K50
  end

  it 'cannot read the top byte of program memory', flaw: true do
    program_memory.read_byte(0x7FFE)
  end

  it 'cannot read the top word of program memory', flaw: true do
    program_memory.read_byte(0x7FFE)
  end

  it 'cannot read the top byte of RAM', flaw: true do
    ram.read_byte(0x0FFF)
  end

  it 'cannot read the top byte of EEPROM', flaw: true do
    eeprom.read_byte(0xFF)
  end

  it 'cannot read the last word of stack memory', flaw: true do
    stack_memory.read_word(31)
  end
end
