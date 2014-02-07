require_relative '../spec_helper'

describe "SFRs" do
  before do
    start_sim Firmware::ReadSFR
  end

  it "can be written and read from Ruby" do
    sfr(:PMADRL).value.should == 0
    sfr(:PMADRL).value = 3
    sfr(:PMADRL).value.should == 3
    run_subroutine :ReadPMADRL, cycle_limit: 100
    x.value.should == 3
  end
  
  it "has the right name" do
    sfr(:PMADRL).name.should == :PMADRL
  end
  
  it "returns the name with #to_s" do
    sfr(:PMADRL).to_s.should == "PMADRL"
  end
  
  it "has a nice inspect function" do
    sfr(:PMADRL).inspect.should == "<RPicSim::Register PMADRL 0x20>"
  end
  
  it "cannot always write to all the bits with #value=" do
    sfr(:STATUS).value = 0
    sfr(:STATUS).value.should == 0b00011000
  end
  
  it "has #memory_value= in case there are some bits we need to change but can't change with value=" do
    sfr(:STATUS).memory_value = 0
    sfr(:STATUS).memory_value.should == 0
    sfr(:STATUS).value.should == 0
  end
end
