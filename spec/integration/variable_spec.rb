require_relative '../spec_helper'

describe 'Variables' do
  before do
    start_sim Firmware::Variables
  end

  it 'can store and retrieve values from an unsigned 8-bit variable' do
    xu8.value = 254
    xu8.value.should == 254
  end

  it 'can store and retrieve values from a signed 8-bit variable' do
    xs8.value = -128
    xs8.value.should == -128
  end

  it 'can store and retrieve values from an unsigned 16-bit variable' do
    xu16.value = 65_000
    xu16.value.should == 65_000
  end

  it 'can store and retrieve values from a signed 16-bit variable' do
    xs16.value = -32_000
    xs16.value.should == -32_000
  end

  it 'can store and retrieve values from an unsigned 24-bit variable' do
    xu24.value = 16_777_215
    xu24.value.should == 16_777_215
  end

  it 'can store and retrieve values from a signed 24-bit variable' do
    xs24.value = -8_388_608
    xs24.value.should == -8_388_608
  end

  it 'can store and retrieve values from an unsigned 32-bit variable' do
    xu32.value = 4_294_967_295
    xu32.value.should == 4_294_967_295
  end

  it 'can store and retrieve values from a signed 32-bit variable' do
    xs32.value = -2_147_483_648
    xs32.value.should == -2_147_483_648
  end

  it 'can be read by the firmware' do
    xu16.value = 70
    yu16.value = 22
    run_subroutine :addition, cycle_limit: 100
    zu16.value.should == 92
  end

end
