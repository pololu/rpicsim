require 'spec_helper'

describe RPicSim::Memory do
  let(:mplab_memory) { double(:mplab_memory) }
  let(:memory) { described_class.new(mplab_memory) }

  describe 'valid_address?' do
    it 'forwards to mplab_memory' do
      expect(mplab_memory).to receive(:valid_address?).with(43).and_return(true)
      expect(memory.valid_address?(43)).to eq true
    end
  end

  describe 'read_byte' do
    it 'forwards to mplab_memory' do
      expect(mplab_memory).to receive(:read_byte).with(44).and_return(7)
      expect(memory.read_byte(44)).to eq 7
    end
  end

  describe 'read_word' do
    it 'forwards to mplab_memory' do
      expect(mplab_memory).to receive(:read_word).with(45).and_return(8)
      expect(memory.read_word(45)).to eq 8
    end
  end

  describe 'write_byte' do
    it 'forwards to mplab_memory' do
      expect(mplab_memory).to receive(:write_byte).with(46, 9)
      memory.write_byte(46, 9)
    end
  end

  describe 'write_word' do
    it 'forwards to mplab_memory' do
      expect(mplab_memory).to receive(:write_word).with(47, 10)
      memory.write_word(47, 10)
    end
  end

  describe 'read_bytes' do
    it 'calls read_byte multiple times' do
      expect(mplab_memory).to receive(:read_byte).with(48).and_return(11)
      expect(mplab_memory).to receive(:read_byte).with(49).and_return(12)
      expect(memory.read_bytes(48, 2)).to eq [11, 12]
    end
  end

  describe 'write_bytes' do
    it 'calls write_byte multiple times' do
      expect(mplab_memory).to receive(:write_byte).with(48, 11)
      expect(mplab_memory).to receive(:write_byte).with(49, 12)
      memory.write_bytes(48, [11, 12])
    end

    it 'returns nil' do
      allow(mplab_memory).to receive(:write_byte) { 33 }
      expect(memory.write_bytes(48, [11, 12])).to eq nil
    end

    it 'can take a string' do
      expect(mplab_memory).to receive(:write_byte).with(48, 11)
      expect(mplab_memory).to receive(:write_byte).with(49, 12)
      expect(memory.write_bytes(48, "\x0B\x0C"))
    end
  end
end
