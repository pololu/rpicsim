require_relative '../spec_helper'

describe RPicSim::Pin do
  let(:pin_physical) { double("pin_physical") }
  let(:mplab_pin) { RPicSim::Mplab::MplabPin.new(pin_physical) }
  subject(:pin) { described_class.new(mplab_pin) }

  describe "#set" do
    it "when given false calls externalSet(PinState::LOW)" do
      pin_physical.should_receive(:externalSet).with(RPicSim::Mdbcore.simulator.Pin::PinState::LOW)
      pin.set(false)
    end

    it "when given true calls externalSet(PinState::HIGH)" do
      pin_physical.should_receive(:externalSet).with(RPicSim::Mdbcore.simulator.Pin::PinState::HIGH)
      pin.set(true)
    end
    
    it "when given a float calls externalSetAnalogValue" do
      pin_physical.should_receive(:externalSetAnalogValue).with(2.3)
      pin.set(2.3)
    end

    it "when given an integer calls externalSetAnalogValue" do
      pin_physical.should_receive(:externalSetAnalogValue).with(2)
      pin.set(2)
    end
    
    it "gives an error if the argument is invalid" do
      expect { pin.set(Object.new) }.to raise_error ArgumentError
    end
  end  
end
