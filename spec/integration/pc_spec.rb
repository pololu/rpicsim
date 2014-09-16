require_relative '../spec_helper'

describe '#pc (program counter)' do
  before do
    start_sim Firmware::NestedSubroutines
  end

  specify '#value tells us the address of the current instruction' do
    expect(pc.value).to eq 0
    step
    expect(pc.value).to eq 0x20
    step
    expect(pc.value).to eq 0x22
  end

  specify '#value= lets us make a different part of the program run' do
    pc.value = 4
    expect(pc.value).to eq 4
    step
    expect(pc.value).to eq 0x100
  end
end

describe '#pc_description' do
  before do
    start_sim Firmware::NestedSubroutines
  end

  it 'returns a nice description of where the PC is (using ProgramFile)' do
    step
    step
    expect(pc_description).to eq '0x0022 = start+0x2'
  end
end
