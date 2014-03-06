require_relative '../spec_helper'

describe 'Program memory variables (midrange)' do
  before do
    start_sim Firmware::FlashVariables
  end
  
  context 'word in normal space (not user id space)' do
    before do
      run_subroutine :setupNormalFlash, cycle_limit: 100
    end
    
    it 'has one address' do
      expect(normalFlashVar.addresses.count).to eq 1
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
  
  context '16-bit integer in normal space' do
    it 'can be read by Ruby' do
      expect(flashu16.value).to eq 0xABCD
    end
    
    it 'when written, only modifies the lower bits' do
      # The program still contains RETLW instructions, which is nice.
      flashu16.value = 0x01FE
      expect(flashu16.value).to eq 0x01FE
      expect(program_memory.read_word(flashu16.address)).to eq 0x34FE
      expect(program_memory.read_word(flashu16.address + 1)).to eq 0x3401
    end
  end

  context 'word in user id space' do
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

describe 'Program memory variables (PIC18)' do
  before do
    start_sim Firmware::Test18F25K50
  end

  context "word in normal space (not user id space)" do
    subject { flashVar1 }
    
    it 'has two address' do
      expect(subject.addresses.count).to eq 2
    end
    
    it 'has the right address (bytes, not words)' do
      expect(subject.address).to eq 0x0020
    end
    
    it 'can be read by Ruby' do
      expect(subject.value).to eq 0xCC33
    end
    
    it 'can be read by the firmware' do
      run_subroutine :readFlashVar1, cycle_limit: 100
      expect(resultVar.value).to eq 0xCC33
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
  end
  
  context '24-bit integer in normal space' do
    it 'can be read by Ruby' do
      expect(flashVar3.value).to eq 0x12CC03
    end
    
    it 'can be written' do
      flashVar3.value = 0x012345
      expect(flashVar3.value).to eq 0x012345
    end
  end
  
end