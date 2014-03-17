require_relative '../spec_helper'

describe RPicSim::ProgramFile do
  subject(:program_file) do
    Firmware::FlashVariables.program_file
  end

  describe '#address_description' do
    specify { subject.address_description(0x0000).should == '0x0000 = setupNormalFlash' }
    specify { subject.address_description(0x0001).should == '0x0001 = setupNormalFlash+0x1' }
    specify { subject.address_description(0x0006).should == '0x0006 = setupUserId0+0x1' }
    specify { subject.address_description(-1).should == '-1' }
  end
end

describe 'Firmware compiled with XC8' do
  before(:all) do
    filename = File.dirname(__FILE__) + '/../firmware/xc8/dist/TestXC8.cof'
    @program_file = RPicSim::ProgramFile.new filename, 'PIC18F25K50'
  end
  
  it 'has main' do
    expect(@program_file.symbols_in_program_memory).to have_key :main
  end
  
  it 'has another function' do
    expect(@program_file.symbols_in_program_memory).to have_key :function1  
  end
  
  it 'has a non-static RAM variable' do
    expect(@program_file.symbols_in_ram[:ramVarUint8]).to eq 0x500
  end
  
  it 'has a static RAM variable' do
    expect(@program_file.symbols_in_ram[:staticRamVarUint8]).to eq 0x501
  end
  
  it 'has a program memory variable' do
    expect(@program_file.symbols_in_program_memory[:flashVarUint16]).to eq 0x1000
  end
  
  it 'has a static program memory variable' do
    expect(@program_file.symbols_in_program_memory[:staticFlashVarUint16]).to eq 0x1002
  end
end