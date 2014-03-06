require_relative '../spec_helper'

describe 'RPicSim::Sim#ram' do
  before do
    start_sim Firmware::Variables
  end

  it 'can write to RAM' do
    address = program_file.symbols_in_ram[:xu8]
    ram.write_byte(address, 255)
    expect(xu8.value).to eq 255
  end

  it 'can write to RAM and then be read by the firmware' do
    ram.write_byte program_file.symbols_in_ram[:xu16], 70
    ram.write_byte program_file.symbols_in_ram[:xu16] + 1, 0
    ram.write_byte program_file.symbols_in_ram[:yu16], 22
    ram.write_byte program_file.symbols_in_ram[:yu16] + 1, 0
    run_subroutine :addition, cycle_limit: 100
    expect(ram.read_byte(program_file.symbols_in_ram[:zu16])).to eq 92
    expect(ram.read_byte(program_file.symbols_in_ram[:zu16] + 1)).to eq 0
  end

  it 'can read from RAM' do
    address = program_file.symbols_in_ram[:xu8]
    xu8.value = 123
    expect(ram.read_byte(address)).to eq 123
  end

  it 'can read from SFRs' do
    reg(:TRISA).value = 0b1010
    expect(ram.read_byte(reg(:TRISA).address)).to eq 0b1010
  end

  it 'can write to SFRs' do
    ram.write_byte(reg(:TRISA).address, 0b1001)
    expect(reg(:TRISA).value).to eq 0b1001
  end

end
