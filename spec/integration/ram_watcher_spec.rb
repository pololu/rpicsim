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
      run_subroutine :SetLClearT, cycle_limit: 100
      sim.ram_watcher.writes[:PORTA].should == 0
      sim.ram_watcher.writes[:LATA].should == nil
    end
  end

end
