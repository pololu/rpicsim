require_relative '../spec_helper'

describe "SFRs as variables" do
  before do
    start_sim Firmware::ReadSFR
  end

  it 'is a variable' do
    expect(register(:PMADRL)).to be_a_kind_of RPicSim::Variable
  end

  it "can be written and read from Ruby" do
    register(:PMADRL).value.should == 0
    register(:PMADRL).value = 3
    register(:PMADRL).value.should == 3
    run_subroutine :ReadPMADRL, cycle_limit: 100
    x.value.should == 3
  end
  
  it "has the right name" do
    register(:PMADRL).name.should == :PMADRL
  end
  
  it "returns the name with #to_s" do
    register(:PMADRL).to_s.should == "PMADRL"
  end
  
  it "has a nice inspect function" do
    register(:PMADRL).inspect.should == "<RPicSim::Variable PMADRL 0x20>"
  end
  
  it "cannot always write to all the bits with #value=" do
    register(:STATUS).value = 0
    register(:STATUS).value.should == 0b00011000
  end
  
  it "has #memory_value= in case there are some bits we need to change but can't change with value=" do
    register(:STATUS).memory_value = 0
    register(:STATUS).memory_value.should == 0
    register(:STATUS).value.should == 0
  end
end

describe '16-bit NMMRs' do
  before do
    start_sim Firmware::Test18F25K50
  end
  subject(:sfr16) { register(:TMR0_Internal) }
  
  it 'is a variable' do
    expect(sfr16).to be_a_kind_of RPicSim::Variable
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
