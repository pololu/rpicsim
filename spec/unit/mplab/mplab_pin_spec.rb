require_relative '../../spec_helper'

describe RPicSim::Mplab::MplabPin do
  let(:pin_physical) { double("pin_physical") }
  subject(:mplab_pin) { described_class.new(pin_physical) }
  let(:pin_state_enum) { RPicSim::Mplab::Mdbcore.simulator.Pin::PinState }
  let(:io_state_enum) { RPicSim::Mplab::Mdbcore.simulator.Pin::IOState }
  
  before do
    allow(pin_physical).to receive(:getIOState).and_return { io_state }
    allow(pin_physical).to receive(:get).and_return { pin_state }
    allow(pin_physical).to receive(:pinName).and_return { pin_name }
  end

  describe "#set_low" do
    it "calls externalSet(PinState::LOW)" do
      pin_physical.should_receive(:externalSet).with(pin_state_enum::LOW)
      mplab_pin.set_low
    end
  end

  describe "#set_high" do
    it "calls externalSet(PinState::HIGH)" do
      pin_physical.should_receive(:externalSet).with(pin_state_enum::HIGH)
      mplab_pin.set_high
    end
  end
    
  describe "#set_analog" do
    [2.3, 2].each do |value|
      context "given #{value}" do
        it "calls externalSetAnalogValue with that value" do
          pin_physical.should_receive(:externalSetAnalogValue).with(value)
          mplab_pin.set_analog(value)
        end
      end
    end
  end

  context "when getIOState returns OUTPUT" do
    let(:io_state) { io_state_enum::OUTPUT }

    specify "#output? returns true" do
      expect(mplab_pin.output?).to eq true
    end
  end

  context "when getIOState returns INPUT" do
    let(:io_state) { io_state_enum::INPUT }

    specify "#output? returns false" do
      expect(mplab_pin.output?).to eq false
    end
  end

  context "when getIOState returns something unusual" do
    let(:io_state) { "foo" }

    specify "#output? raises an exception" do
      expect {mplab_pin.output?}.to raise_exception "Invalid IO state: foo"
    end
  end

  context "when driving high" do
    let(:pin_state) { pin_state_enum::HIGH }

    specify "#high? returns true" do
      expect(mplab_pin.high?).to eq true
    end
  end

  context "when driving low" do
    let(:pin_state) { pin_state_enum::LOW }

    specify "#high? returns false" do
      expect(mplab_pin.high?).to eq false
    end
  end

  context "when PinState is some other value" do
    let(:pin_state) { "bar" }

    specify "#high? raises an exception" do
      expect {mplab_pin.high?}.to raise_exception "Invalid pin state: bar"
    end
  end

  context "when pin_physical is an enumerable of items responding to #name" do
    let(:signal1) { double("Object", name: "signal1") }
    let(:signal2) { double("Object", name: "signal2") }
    let(:pin_physical) { [signal1, signal2] }

    specify "#names returns all the names" do
      expect(mplab_pin.names).to eq ["signal1", "signal2"]
    end
  end

  context 'when pinName returns "foo"' do
    let(:pin_name) { 'foo' }

    specify '#name returns "foo"' do
      expect(mplab_pin.name).to eq 'foo'
    end
  end
end

describe "assumptions about MPLAB X used to build MplabPin" do
  let(:pin) { com.microchip.mplab.mdbcore.simulator.Pin }
  
  specify "the two PinStates are HIGH and LOW" do
    pin::PinState.constants.sort.should == [:HIGH, :LOW]
  end
  
  specify "the two IOStates are INPUT and OUTPUT" do
    pin::IOState.constants.sort.should == [:INPUT, :OUTPUT]
  end
end

