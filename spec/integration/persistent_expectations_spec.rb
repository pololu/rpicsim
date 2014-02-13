require_relative '../spec_helper'

# This is a series of tests for the persistent expectations module.

describe RPicSim::RSpec::PersistentExpectations do
  before do
    start_sim Firmware::PinMirror
  end

  it "checks persistent expectations every step after they are set up" do
    # make the output low
    pin(:RA0).set false
    run_cycles 10
    
    # we should get an error on the NEXT step if we expect high
    expecting pin(:RA1) => be_driving_high
    old_cycle_count = cycle_count
    expect { step }.to raise_error

    # verify that the processor is running
    expect(cycle_count - old_cycle_count).to be > 0

    # we sould not get an error on the step if we expect low 
    expecting pin(:RA1) => be_driving_low
    expect { step }.to_not raise_error

    # clear expectation
    expecting pin(:RA1) => nil

    # make the output high
    pin(:RA0).set true
    run_cycles 10
    
    # we should get an error on the NEXT step if we expect low
    expecting pin(:RA1) => be_driving_low
    old_cycle_count = cycle_count
    expect { step }.to raise_error

    # we sould not get an error on the step if we expect high
    expecting pin(:RA1) => be_driving_high
    expect { step }.to_not raise_error
  end

  it "checks persistent expectations in a block" do
    # make the output low
    pin(:RA0).set false
    run_cycles 10
    
    # we should get an error on the NEXT step if we expect high
    test = double(:object)
    test.should_receive(:hello).once
    expecting(pin(:RA1) => be_driving_high) do
      test.hello
      expect { step }.to raise_error
    end

    # clearing should not be necessary after a block
    expect { step }.to_not raise_error
  end
end
