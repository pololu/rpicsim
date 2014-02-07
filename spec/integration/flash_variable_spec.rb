require_relative '../spec_helper'

describe "Flash variables" do
  before do
    start_sim Firmware::FlashVariables
  end
  
  context "in normal space (not user id space)" do
    before do
      run_subroutine :setupNormalFlash, cycle_limit: 100
    end
  
    it "can be read by Ruby" do
      normalFlashVar.value.should == 0x801
    end

    it "can be read by the firmware" do
      run_subroutine :readX, cycle_limit: 100
      x.value.should == 0x801
    end
    
    it "can be written by Ruby" do
      normalFlashVar.value = 700
      normalFlashVar.value.should == 700
    end
    
    it "can be read by the firmware after being written by Ruby" do
      normalFlashVar.value = 0xA0E
      run_subroutine :readX, cycle_limit: 100
      x.value.should == 0xA0E
    end
    
    it "can be written by firmware" do
      x.value = 0xE23
      run_subroutine :saveX, cycle_limit: 20000
      normalFlashVar.value.should == 0xE23
    end
  end

  context "in user id space" do
    before do
      run_subroutine :setupUserId0, cycle_limit: 100
    end

    describe "do not get loaded correctly from COF file", flaw: true do
      # The workaround is to simply set the flash variables to the correct values from Ruby
      # and we have tests below to prove that works.
    
      it "initial value cannot be read by ruby", flaw: true do
        [userId0, userId1, userId2, userId3].collect(&:value).should == [0x3FFF] * 4  # bad
      end

      it "initial value cannot be read by the firmware", flaw: true do
        run_subroutine :readX, cycle_limit: 100
        x.value.should == 0x3FFF  # bad
      end
    end
        
    it "can be written by Ruby" do
      userId0.value = 700
      userId0.value.should == 700
    end

    it "can be read by the firmware after being written by Ruby" do
      userId0.value = 0xA0E
      run_subroutine :readX, cycle_limit: 100
      x.value.should == 0xA0E
    end
    
    it "can be written by firmware except in MPLAB X 1.85", flaw: true do
      # This flaw was reported and fixed:
      # http://www.microchip.com/forums/m743214.aspx
    
      x.value = 0xE23
      run_subroutine :saveX, cycle_limit: 20000
      
      expected = RPicSim::Flaws[:firmware_cannot_write_user_id0] ? 0x3FFF : 0xE23
      userId0.value.should == expected
    end
  end

end
