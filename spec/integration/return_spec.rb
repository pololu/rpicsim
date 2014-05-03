require_relative '../spec_helper'

describe '#return' do
  before do
    start_sim Firmware::NestedSubroutines
  end

  it 'pops the top value off the stack and sets the PC equal to it' do
    run_to :ioo, cycle_limit: 100
    sim.stack_contents.should == [0x23, 0x42, 0x61]
    pc.value.should == 0x80

    sim.return
    sim.stack_contents.should == [0x23, 0x42]
    pc.value.should == 0x61
  end

  it 'raises an error if the stack is empty' do
    expect { sim.return }.to raise_error 'Cannot return because stack is empty.'
  end

end

describe '#return for a PIC18 device' do
  before do
    start_sim Firmware::Test18F25K50
  end

  it 'updates TOSU:TOSH:TOSL after returning' do
    # This is necessary because apparently the simulator sets PC equal to
    # TOSU:TOSH:TOSL when it executes a return/retlw/retfie instruction,
    # instead of actually reading from the stack memory.
    stack_push 0x123456
    stack_push label(:start).address
    sim.return
    tos = [reg(:TOSU).value, reg(:TOSH).value, reg(:TOSL).value]
    expect(tos).to eq [0x12, 0x34, 0x56]
  end
end


describe '#return for an enhanced midrange device' do
  before do
    start_sim Firmware::Test16F1826
  end

  it 'removes a value from the stack' do
    sim.stack_push 1
    sim.return
    expect(sim.stack_contents).to eq []
  end

  it 'raises an error if the stack is empty' do
    expect { sim.return }.to raise_error 'Cannot return because stack is empty.'
  end
end
