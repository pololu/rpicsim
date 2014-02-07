require_relative '../spec_helper'

describe "#pc (program counter)" do
  before do
    start_sim Firmware::NestedSubroutines
  end
  
  specify "#value tells us the address of the current instruction" do
    pc.value.should == 0
    step
    pc.value.should == 0x20
    step
    pc.value.should == 0x22
  end
  
  specify "#value= lets us make a different part of the program run" do
    pc.value = 4
    pc.value.should == 4
    step
    pc.value.should == 0x100
  end
end

describe "#pc_description" do
  before do
    start_sim Firmware::NestedSubroutines
  end

  it "returns a nice description of where the PC is (using ProgramFile)" do
    step
    step
    pc_description.should == "0x0022 = start+0x2"
  end
end
