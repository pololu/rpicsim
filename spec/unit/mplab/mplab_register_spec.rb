require_relative '../../spec_helper'

describe RPicSim::Mplab::MplabRegister do
  let(:register) { double('register') }
  subject(:mplab_register) { described_class.new(register) }

  describe '#write' do
    it 'writes to the register and returns the value written' do
      expect(register).to receive(:write).with(40).and_return { nil }
      return_value = mplab_register.write(40)
      expect(return_value).to eq 40
    end
  end

  describe '#read' do
    it 'reads from the register' do
      expect(register).to receive(:read).and_return { 40 }
      expect(mplab_register.read).to eq 40
    end
  end

  describe '#name' do
    it 'just defers to getName' do
      expect(register).to receive(:getName).and_return { 'LATA' }
      expect(mplab_register.name).to eq 'LATA'
    end
  end

  describe '#address' do
    it 'just defers to getAddress' do
      expect(register).to receive(:getAddress).and_return { 2 }
      expect(mplab_register.address).to eq 2
    end
  end

end