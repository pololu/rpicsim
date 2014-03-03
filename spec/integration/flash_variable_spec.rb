require_relative '../spec_helper'

describe "Flash variables (midrange)" do
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
        
    it "can be written by Ruby" do
      userId0.value = 700
      userId0.value.should == 700
    end

    it "can be read by the firmware after being written by Ruby" do
      userId0.value = 0xA0E
      run_subroutine :readX, cycle_limit: 100
      x.value.should == 0xA0E
    end
  end

end

describe 'Flash variables (PIC18)' do
  before do
    start_sim Firmware::Test18F25K50
  end

  context "in normal space (not user id space)" do
    subject { flashVar1 }
    
    it 'has the right address (bytes, not words)' do
      expect(subject.address).to eq 0x0020
    end
    
    it 'can be read by Ruby' do
      expect(subject.value).to eq 0x5544
    end
    
    it 'can be read by the firmware' do
      run_subroutine :readFlashVar1, cycle_limit: 100
      expect(resultVar.value).to eq 0x5544
    end
    
    it 'can be written by Ruby' do
      subject.value = 0xCCDD
      expect(subject.value).to eq 0xCCDD
    end
    
    it 'can be read by firmware after being written by Ruby' do
      subject.value = 0x0A0E
      run_subroutine :readFlashVar1, cycle_limit: 100
      expect(resultVar.value).to eq 0x0A0E
    end
    
    # TODO: test that flash writes on the PIC18F25K50 can be simulated
  end
  
end