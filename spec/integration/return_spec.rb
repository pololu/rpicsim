require 'spec_helper'

describe "#return" do
  before do
    start_sim Firmware::NestedSubroutines
  end
  
  it "pops the top value off the stack and sets the PC equal to it" do
    run_to :ioo, cycle_limit: 100
    pic.stack_contents.should == [0x23, 0x42, 0x61]
    pc.value.should == 0x80
    
    pic.return
    pic.stack_contents.should == [0x23, 0x42]
    pc.value.should == 0x61
  end

  it "gives an error if the stack is empty" do
    expect { pic.return }.to raise_error "Cannot return because stack pointer is 0."
  end
  
end