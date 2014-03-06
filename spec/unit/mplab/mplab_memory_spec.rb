require_relative '../../spec_helper'

describe RPicSim::Mplab::MplabMemory do
  let(:memory) { double('memory') }
  subject(:mplab_memory) { described_class.new(memory) }

  describe '#read_byte' do
    it 'reads a single, unsigned byte' do
      expect(memory).to receive(:Read) do |address, size, bytes|
        expect(address).to eq 12
        expect(size).to eq 1
        expect(bytes).to be_a_kind_of Java::byte[]
        expect(bytes.size).to eq 1
        bytes.ubyte_set(0, 0x9B)
      end
      expect(mplab_memory.read_byte(12)).to eq 0x9B
    end
  end

  describe '#write_byte' do
    it 'writes a single, unsigned byte and returns the value written' do
      expect(memory).to receive(:Write) do |address, size, bytes|
        expect(address).to eq 12
        expect(size).to eq 1
        expect(bytes).to be_a_kind_of Java::byte[]
        expect(bytes.size).to eq 1
        expect(bytes.ubyte_get(0)).to eq 0x9B
      end
      return_value = mplab_memory.write_byte(12, 0x9B)
      expect(return_value).to eq 0x9B
    end
  end

  describe '#read_word' do
    it 'reads memory' do
      expect(memory).to receive(:ReadWord).with(12).and_return { 40 }
      expect(mplab_memory.read_word(12)).to eq 40
    end
  end

  describe '#write_word' do
    it 'writes to memory and returns the value written' do
      expect(memory).to receive(:WriteWord).with(12, 40).and_return { nil }
      return_value = mplab_memory.write_word(12, 40)
      expect(return_value).to eq 40
    end
  end

  describe '#valid_address?' do
    it 'just defers to IsValidAddress' do
      expect(memory).to receive(:IsValidAddress).with(22).and_return { true }
      expect(mplab_memory.valid_address?(22)).to eq true
    end
  end

end