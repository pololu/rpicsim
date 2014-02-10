require_relative '../spec_helper'

describe RPicSim::MplabPin do
  let(:pin_physical) { double("pin_physical") }
  subject(:mplab_pin) { described_class.new(pin_physical) }

  before do
    allow(pin_physical).to receive(:getIOState).and_return { io_state }
    allow(pin_physical).to receive(:get).and_return { pin_state }
    allow(pin_physical).to receive(:pinName).and_return { pin_name }
  end

  describe "#set_low" do
    it "calls externalSet(PinState::LOW)" do
      pin_physical.should_receive(:externalSet).with(RPicSim::Mdbcore.simulator.Pin::PinState::LOW)
      mplab_pin.set_low
    end
  end

  describe "#set_high" do
    it "calls externalSet(PinState::HIGH)" do
      pin_physical.should_receive(:externalSet).with(RPicSim::Mdbcore.simulator.Pin::PinState::HIGH)
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
    let(:io_state) { RPicSim::Mdbcore.simulator.Pin::IOState::OUTPUT }

    specify "#output? returns true" do
      expect(mplab_pin.output?).to eq true
    end
  end

  context "when getIOState returns INPUT" do
    let(:io_state) { RPicSim::Mdbcore.simulator.Pin::IOState::INPUT }

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
    let(:pin_state) { RPicSim::Mdbcore.simulator.Pin::PinState::HIGH }

    specify "#high? returns true" do
      expect(mplab_pin.high?).to eq true
    end
  end

  context "when driving low" do
    let(:pin_state) { RPicSim::Mdbcore.simulator.Pin::PinState::LOW }

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

    # TODO - test for mutability of these strings
  end

  context 'when pinName returns "foo"' do
    let(:pin_name) { 'foo' }

    specify '#name returns "foo"' do
      expect(mplab_pin.name).to eq 'foo'
    end
  end
end
