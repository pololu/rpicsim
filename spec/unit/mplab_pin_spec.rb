require_relative '../spec_helper'

describe RPicSim::MplabPin do
  let(:pin_physical) { double("pin_physical") }
  subject(:mplab_pin) { described_class.new(pin_physical) }

  before do
    allow(pin_physical).to receive(:getIOState).and_return { io_state }
  end

  describe "#set_low" do
    it "calls externalSet(PinState::LOW)" do
      pin_physical.should_receive(:externalSet).with(described_class::PinState::LOW)
      mplab_pin.set_low
    end
  end

  describe "#set_high" do
    it "calls externalSet(PinState::HIGH)" do
      pin_physical.should_receive(:externalSet).with(described_class::PinState::HIGH)
      mplab_pin.set_high
    end
  end
    
  describe "#set_analog" do
    [2.3, 2].each do |value|
      context "given #{value}" do
        let(:value) { value }
        it "calls externalSetAnalogValue with that value" do
          pin_physical.should_receive(:externalSetAnalogValue).with(value)
          mplab_pin.set_analog(value)
        end
      end
    end
  end

  {
    RPicSim::Mdbcore.simulator.Pin::IOState::OUTPUT => true,
    RPicSim::Mdbcore.simulator.Pin::IOState::INPUT => false
  }.each do |io_state, value|

    context "when getIOState returns #{io_state}" do
      let(:io_state) { io_state }

      specify "#output? returns #{value}" do
        expect(mplab_pin.output?).to eq value
      end

      specify "#input? returns #{!value}" do
        expect(mplab_pin.input?).to eq !value
      end
    end
  end

  context "when getIOState returns something unusual" do
    let(:io_state) { "foo" }

    specify "#output? raises" do
      expect {mplab_pin.output?}.to raise_exception
    end

    specify "#input? raises" do
      expect {mplab_pin.input?}.to raise_exception
    end
  end
end
