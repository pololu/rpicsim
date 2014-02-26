require_relative '../spec_helper'
# This is an integration test for Sim#ram_watcher,
# so it tests the Sim class, MemoryWatcher class, and MPLAB X.

# NOTE: None of these specs work for MPLAB X 1.95 (and probably later) because
# Memory.Attach on the RAM memory got severely messed up in MPLAB X 1.95.
# See spec/mplab_x/memory_attach_spec.rb for more information.
if !RPicSim::Flaws[:fr_memory_attach_useless]

  describe "Sim#ram_watcher" do
    it "sees RAM variables written by the test" do
      start_sim Firmware::Addition
      step
      sim.ram_watcher.clear
      x.value = 255
      y.value = 20
      step
      sim.ram_watcher.writes.should == { x: 255, y: 20 }
    end

    it "sees when the firmware writes to RAM variables" do
      start_sim Firmware::Addition
      x.value = 255
      y.value = 20
      step
      sim.ram_watcher.clear
      run_subroutine :addition, cycle_limit: 100
      sim.ram_watcher.writes.should == { z: 275 }
    end

    it "sees when the firmware writes to an unnamed part of RAM" do
      start_sim Firmware::WriteTo5F
      step
      sim.ram_watcher.clear
      run_subroutine :WriteTo5F, cycle_limit: 100
      sim.ram_watcher.writes.should == { 0x5F => 44 }
    end
    
    it "sees when the firmware writes to an SFR" do
      start_sim Firmware::DrivePinHigh
      run_subroutine :ClearAClearTSetL, cycle_limit: 100
      sim.ram_watcher.writes[:TRISA].should == 14
    end
    
    it "confuses writes to LATA with writes to PORTA when ANSELA bits are 1 and TRISA bits are 1", flaw: true do
      start_sim Firmware::DrivePinHigh
      step
      sim.ram_watcher.clear
      run_subroutine :SetLClearT, cycle_limit: 100
      sim.ram_watcher.writes[:PORTA].should == 0
      sim.ram_watcher.writes[:LATA].should == 1
    end
    
    it 'reports a write for each address of PCL whenever it changes', flaw: true do
      # The same is presumably true for the other core registers with multiple addresses,
      # like WREG.
      start_sim Firmware::Test16F1826
      goto :testNops
      step
      ram_watcher.clear
      step
      ram_watcher.writes.keys.should eq 130.step(3970, 128).to_a
    end
  end

end
