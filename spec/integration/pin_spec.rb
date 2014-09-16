require_relative '../spec_helper'

describe 'Pic#pin' do
  it 'lets you read the state of pins' do
    start_sim Firmware::DrivePinHigh
    expect(pin(:RA0)).to be_input
    expect(pin(:RA0)).to_not be_output
    run_subroutine :ClearAClearTSetL, cycle_limit: 100
    expect(pin(:RA0)).to be_output
    expect(pin(:RA0)).to_not be_input
    expect(pin(:RA0)).to_not be_driving_low
    expect(pin(:RA0)).to be_driving_high
  end

  it 'can drive an input pin high' do
    start_sim Firmware::ReadPin
    pin(:RA0).set(true)
    run_subroutine :ClearAnselAndReadPin
    expect(x.value).to eq 1
  end

  it 'cannot set pin value if ANSELA bit is 1' do
    # If ANSELA is 1, the digital input buffer is disabled.
    start_sim Firmware::ReadPin
    pin(:RA0).set(true)
    run_subroutine :ReadPin
    expect(x.value).to eq 0
  end

  it 'does not get messed up if we write to TRISA (like the output state does)' do
    start_sim Firmware::ReadPin
    pin(:RA0).set(true)
    run_subroutine :ClearASetTReadPin
    expect(x.value).to eq 1
  end

  it 'reports the wrong output state if the ANSELx bit is 1', flaw: true do
    start_sim Firmware::DrivePinHigh
    run_subroutine :ClearTSetL, cycle_limit: 100
    expect(pin(:RA0)).to be_driving_low  # flaw
  end

  it 'reports the wrong output state if LATx is set before TRISx', flaw: true do
    # Flaw confirmed for MPLAB X 1.85.
    start_sim Firmware::DrivePinHigh
    run_subroutine :SetLClearT, cycle_limit: 100
    expect(pin(:RA0)).to be_driving_low  # flaw
  end

  it 'could reports the wrong output state if TRISx is cleared again' do
    start_sim Firmware::DrivePinHigh
    goto :ClearAClearTSetLClearT
    step  # clear ANSELA
    step  # clear TRISA
    step  # set LATA
    expect(pin(:RA0)).to be_driving_high  # good
    expect(reg(:LATA).value).to eq 1      # good
    step  # clear TRISA again
    expect(reg(:LATA).value).to eq 1      # good

    if RPicSim::Flaws[:writing_tris_affects_output]
      expect(pin(:RA0)).to be_driving_low   # bad
    else
      expect(pin(:RA0)).to be_driving_high  # good
    end
  end

  it 'knows its names' do
    start_sim Firmware::DrivePinHigh
    expect(pin(:RA0).names.sort).to eq %w{RA0 PWM1 CLC1IN1 CWG1A AN0 ICSPDAT}.sort
  end

  specify '#inspect shows the class name and pin names' do
    start_sim Firmware::DrivePinHigh
    expect(pin(:RA0).inspect).to eq '#<RPicSim::Pin RA0/PWM1/CLC1IN1/CWG1A/AN0/ICSPDAT>'
  end

  it 'can be defined in the class definition with def_pin' do
    start_sim Firmware::ReadPin
    expect(main_pin).to eq pin(:RA0)
  end
end
