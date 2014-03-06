require_relative '../spec_helper'

describe RPicSim::CompositeMemory do
  before do
    @mem1 = double('mem1')
    @mem2 = double('mem2')
    @composite_memory = described_class.new [@mem1, @mem2]
  end

  it 'raises a good error message for invalid addresses' do
    expect(@mem1).to receive(:valid_address?).with(0x40).and_return(false).exactly(2).times
    expect(@mem2).to receive(:valid_address?).with(0x40).and_return(false).exactly(2).times
    expect { @composite_memory.read_word(0x40) }.to raise_error 'Invalid memory address 0x40.'
    expect { @composite_memory.write_word(0x40, 0) }.to raise_error 'Invalid memory address 0x40.'
  end

  it 'uses the first memory if it can, without considering the second' do
    expect(@mem1).to receive(:valid_address?).with(0x40).and_return(true).exactly(2).times
    expect(@mem1).to receive(:read_word).with(0x40).and_return(0x41)
    expect(@mem1).to receive(:write_word).with(0x40, 0)

    expect(@composite_memory.read_word(0x40)).to eq 0x41
    @composite_memory.write_word(0x40, 0)
  end

  it 'uses the second memory if needed' do
    expect(@mem1).to receive(:valid_address?).with(0x40).and_return(false).exactly(2).times
    expect(@mem2).to receive(:valid_address?).with(0x40).and_return(true).exactly(2).times
    expect(@mem2).to receive(:read_word).with(0x40).and_return(0x41)
    expect(@mem2).to receive(:write_word).with(0x40, 0)

    expect(@composite_memory.read_word(0x40)).to eq 0x41
    @composite_memory.write_word(0x40, 0)
  end

  describe 'valid_address?' do
    it 'returns false if the address is invalid in all component memories' do
      expect(@mem1).to receive(:valid_address?).with(0x40).and_return(false)
      expect(@mem2).to receive(:valid_address?).with(0x40).and_return(false)
      expect(@composite_memory.valid_address?(0x40)).to eq false
    end

    it 'returns true if the address is valid in either memory' do
      expect(@mem1).to receive(:valid_address?).with(0x40).and_return(false)
      expect(@mem2).to receive(:valid_address?).with(0x40).and_return(true)
      expect(@composite_memory.valid_address?(0x40)).to eq true
    end
  end

end