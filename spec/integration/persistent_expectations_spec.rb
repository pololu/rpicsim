require_relative '../spec_helper'

class IntentionalError < Exception
end

# This is a series of tests for the persistent expectations module.

describe RPicSim::RSpec::PersistentExpectations do
  before do
    start_sim Firmware::PinMirror

    # make the output low
    pin(:RA0).set false
    run_cycles 10
  end

  it "checks persistent expectations every step after they are set up" do
    # we should get an error on the NEXT step if we expect high
    expecting pin(:RA1) => be_driving_high
    old_cycle_count = cycle_count
    expect { step }.to raise_error RSpec::Expectations::ExpectationNotMetError

    # verify that the processor did take a step
    expect(cycle_count - old_cycle_count).to be_between(1, 2)

    # we should not get an error on the step if we expect low 
    expecting pin(:RA1) => be_driving_low
    expect { step }.to_not raise_error

    # clear expectation
    expecting pin(:RA1) => nil

    # make the output high
    pin(:RA0).set true
    run_cycles 10
    
    # we should get an error on the NEXT step if we expect low
    expecting pin(:RA1) => be_driving_low
    expect { step }.to raise_error RSpec::Expectations::ExpectationNotMetError

    # we should not get an error on the step if we expect high
    expecting pin(:RA1) => be_driving_high
    expect { step }.to_not raise_error
  end

  it "checks persistent expectations in a block" do
    # we should get an error on the NEXT step if we expect high
    test = double(:object)
    test.should_receive(:hello).once
    expecting(pin(:RA1) => be_driving_high) do
      test.hello
      expect { step }.to raise_error RSpec::Expectations::ExpectationNotMetError
    end

    # clearing should not be necessary after a block
    expect { step }.to_not raise_error
  end

  it "restores expectations if a block raises an exception" do
    begin
      expecting(pin(:RA1) => be_driving_high) do
        raise IntentionalError
      end
    rescue IntentionalError
    end

    expect(expectations).to eq({})
  end

  it "restores nested expectations" do
    low = be_driving_low
    high = be_driving_low

    expecting(pin(:RA1) => high) do
      expecting(pin(:RA1) => low) do
        expect(expectations[pin(:RA1)]).to be low
      end
      expect(expectations[pin(:RA1)]).to be high
    end
    expect(expectations[pin(:RA1)]).to eq nil
  end


end
