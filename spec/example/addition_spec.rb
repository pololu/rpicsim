require_relative '../spec_helper'

describe "addition" do
  before do
    start_sim Firmware::Addition
  end

  it "adds x to y and stores the result in z" do
    x.value = 70
    y.value = 22
    step
    ram_watcher = new_ram_watcher
    run_subroutine :addition, cycle_limit: 100
    expect(ram_watcher.writes).to eq({z: 92})
  end unless RPicSim::Flaws[:fr_memory_attach_useless]
end
