require_relative '../spec_helper'

describe 'RPicSim::Sim#ram' do
  before do
    start_sim Firmware::Variables
  end
  
  it 'can write to RAM' do
    address = program_file.var_addresses[:xu8]
    ram[address] = 255
    expect(xu8.value).to eq 255
  end
  
  it 'can write to RAM and then be read by the firmware' do
    ram[program_file.var_addresses[:xu16]] = 70
    ram[program_file.var_addresses[:xu16] + 1] = 0
    ram[program_file.var_addresses[:yu16]] = 22
    ram[program_file.var_addresses[:yu16] + 1] = 0
    run_subroutine :addition, cycle_limit: 100
    expect(ram[program_file.var_addresses[:zu16]]).to eq 92
    expect(ram[program_file.var_addresses[:zu16] + 1]).to eq 0
  end
  
  it 'can read from RAM' do
    address = program_file.var_addresses[:xu8]
    xu8.value = 123
    expect(ram[address]).to eq 123
  end

  it 'can read from SFRs' do
    reg(:TRISA).value = 0b1010
    expect(ram[reg(:TRISA).address]).to eq 0b1010
  end
  
  it 'can write to SFRs' do
    ram[reg(:TRISA).address] = 0b1001
    expect(reg(:TRISA).value).to eq 0b1001
  end
  
end
