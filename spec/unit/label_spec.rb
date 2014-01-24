require 'spec_helper'

describe RPicSim::Label do
  let(:label) do
    described_class.new(:foo, 0x123)
  end
  
  it "stores the name" do
    label.name.should == :foo
  end
  
  it "stores the address" do
    label.address.should == 0x123
  end
  
  it "returns the address for #to_i" do
    label.to_i.should == 0x123
  end
  
  it "has a nice to_s method" do
    label.to_s.should == "<Label foo address=0x123>"
  end

end