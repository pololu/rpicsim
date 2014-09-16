require_relative '../spec_helper'

describe 'Variables' do
  before do
    start_sim Firmware::Variables
  end

  it 'can store and retrieve values from an unsigned 8-bit variable' do
    xu8.value = 254
    expect(xu8.value).to eq 254
  end

  it 'can store and retrieve values from a signed 8-bit variable' do
    xs8.value = -128
    expect(xs8.value).to eq -128
  end

  it 'can store and retrieve values from an unsigned 16-bit variable' do
    xu16.value = 65_000
    expect(xu16.value).to eq 65_000
  end

  it 'can store and retrieve values from a signed 16-bit variable' do
    xs16.value = -32_000
    expect(xs16.value).to eq -32_000
  end

  it 'can store and retrieve values from an unsigned 24-bit variable' do
    xu24.value = 16_777_215
    expect(xu24.value).to eq 16_777_215
  end

  it 'can store and retrieve values from a signed 24-bit variable' do
    xs24.value = -8_388_608
    expect(xs24.value).to eq -8_388_608
  end

  it 'can store and retrieve values from an unsigned 32-bit variable' do
    xu32.value = 4_294_967_295
    expect(xu32.value).to eq 4_294_967_295
  end

  it 'can store and retrieve values from a signed 32-bit variable' do
    xs32.value = -2_147_483_648
    expect(xs32.value).to eq -2_147_483_648
  end

  it 'can be read by the firmware' do
    xu16.value = 70
    yu16.value = 22
    run_subroutine :addition, cycle_limit: 100
    expect(zu16.value).to eq 92
  end

end
