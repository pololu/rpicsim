# coding: UTF-8

# Parts of this are used in docs/Pins.md

require_relative '../spec_helper'

describe "PinMirror" do
  before do
    start_sim Firmware::PinMirror
    pic.frequency_mhz = 1
  end

  context "when RA0 input is high" do
    before do
      pin(:RA0).set true
    end

    it "drives RA1 high" do
      run_cycles 10
      pin(:RA1).should be_driving_high
    end
  end

  context "when RA0 input is low" do
    before do
      pin(:RA0).set false
    end

    it "drives RA1 high" do
      run_cycles 10
      pin(:RA1).should be_driving_low
    end
  end

  it "continuously mirrors" do
    main_input.set false
    run_cycles 10
    expect(main_output).to be_driving_low

    run_cycles 10
    expect(main_output).to be_driving_low

    main_input.set true
    run_cycles 10
    expect(main_output).to be_driving_high

    run_cycles 10
    expect(main_output).to be_driving_high

    main_input.set false
    run_cycles 10
    expect(main_output).to be_driving_low
  end

  it "mirrors the main input onto the main output pin" do
    run_µs 30    # Give the device time to start up.

    expecting main_output => be_driving_low
    run_µs 200

    main_input.set true

    # Turn off the persistent expectation temporarily to give the device
    # time to detect the change in the input.
    expecting main_output => nil
    run_µs 50

    expecting main_output => be_driving_high
    run_µs 200
  end
end