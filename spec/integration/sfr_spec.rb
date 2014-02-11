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

describe '16-bit NMMRs' do
  before do
    start_sim Firmware::Test18F25K50
  end
  subject(:sfr16) { nmmr(:TMR0_Internal) }
  
  it 'should have a size of 2' do
    expect(sfr16.size).to eq 2
  end
  
  it 'should take up two byte addresses' do
    expect(sfr16.addresses.count).to eq 2
  end
  
  it 'can be read and written with #memory_value' do
    sfr16.memory_value = 0x1234
    expect(sfr16.memory_value).to eq 0x1234
  end

  context 'in the case of TMR0_Internal' do
    it 'can only read the LSb with #value', flaw: true do
      sfr16.memory_value = 0x1234
      expect(sfr16.value).to eq 0x34
    end
  
    it 'cannot be written with #value', flaw: true do
      sfr16.value = 0x1234
      expect(sfr16.memory_value).to eq 0
      expect(sfr16.value).to eq 0
    end
  end
 
end
