require_relative '../../spec_helper'

describe RPicSim::Mplab::MplabMemory do
  let(:memory) { double('memory') }
  subject(:mplab_memory) { described_class.new(memory) }
  
  describe '#write_word' do
    it 'writes to memory and returns the value written' do
      expect(memory).to receive(:WriteWord).with(12, 40).and_return { nil }
      return_value = mplab_memory.write_word(12, 40)
      expect(return_value).to eq 40
    end
  end
  
  describe '#read_word' do
    it 'reads memory' do
      expect(memory).to receive(:ReadWord).with(12).and_return { 40 }
      expect(mplab_memory.read_word(12)).to eq 40
    end
  end
  
  describe '#is_valid_address?' do
    it 'just defers to IsValidAddress' do
      expect(memory).to receive(:IsValidAddress).with(22).and_return { true }
      expect(mplab_memory.is_valid_address?(22)).to eq true
    end
  end
  
end