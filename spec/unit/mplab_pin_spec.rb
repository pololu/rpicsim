require_relative '../spec_helper'

describe RPicSim::MplabPin do
  let(:pin_physical) { double("pin_physical") }
  subject(:mplab_pin) { described_class.new(pin_physical) }

  describe "#set" do
    it "set_low calls externalSet(PinState::LOW)" do
      pin_physical.should_receive(:externalSet).with(described_class::PinState::LOW)
      mplab_pin.set_low
    end

    it "set_high calls externalSet(PinState::HIGH)" do
      pin_physical.should_receive(:externalSet).with(described_class::PinState::HIGH)
      mplab_pin.set_high
    end
    
    it "set_analog calls externalSetAnalogValue" do
      pin_physical.should_receive(:externalSetAnalogValue).with(2.3)
      mplab_pin.set_analog(2.3)
    end

    it "set_analog with integer also calls externalSetAnalogValue" do
      pin_physical.should_receive(:externalSetAnalogValue).with(2)
      mplab_pin.set_analog(2)
    end
  end  
end
