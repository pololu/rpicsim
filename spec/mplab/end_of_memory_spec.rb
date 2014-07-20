# MPLABX generally doesn't let us access the last byte/word of memory.

require 'spec_helper'

describe 'end-of-memory issues (PIC18)' do
  before do
    start_sim Firmware::Test18F25K50
  end

  it 'cannot read the top byte of program memory', flaw: true do
    expect(program_memory.valid_address?(0x7FFE)).to eq true  # good
    expect(program_memory.valid_address?(0x7FFF)).to eq false # bad
  end
end

describe 'end-of-memory issues (enhanced midrange)' do
  before do
    start_sim Firmware::Test16F1826
  end

  it 'can read the top word of program memory' do
    expect(program_memory.valid_address?(0x7FF)).to eq true
    expect(program_memory.valid_address?(0x800)).to eq false
  end
end

describe 'end-of-memory issues (midrange)' do
  before do
    start_sim Firmware::Test10F322
  end

  it 'can read the top word of program memory' do
    expect(program_memory.valid_address?(0x1FF)).to eq true
    expect(program_memory.valid_address?(0x200)).to eq false
  end
end

describe 'end-of-memory issues (baseline)' do
  before do
    start_sim Firmware::Test10F202
  end

  it 'can read the top word of program memory' do
    expect(program_memory.valid_address?(0x23F)).to eq true
    expect(program_memory.valid_address?(0x240)).to eq false
    # Butt this chip is only supposed to have 0x200 words so this is weird
    # and might be another bug.
  end
end
