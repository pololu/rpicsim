require_relative '../spec_helper'

describe 'RPicSim::Sim#program_memory' do
  before do
    start_sim Firmware::FlashVariables
  end
  
  context 'normal space (not user id space)' do
    before do
      run_subroutine :setupNormalFlash, cycle_limit: 100
    end
  
    it 'can be read by Ruby' do
      expect(program_memory[0x100]).to eq 0x801
    end

    it 'can be written by Ruby' do
      program_memory[0x100] = 0x700
      expect(program_memory[0x100]).to eq 0x700
    end
    
    it 'can be read by the firmware after being written by Ruby' do
      program_memory[0x100] = 0xA0E
      run_subroutine :readX, cycle_limit: 100
      expect(x.value).to eq 0xA0E
    end
    
    it 'can be written by firmware' do
      x.value = 0xE23
      run_subroutine :saveX, cycle_limit: 20000
      expect(program_memory[0x100]).to eq 0xE23
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
        ids = (0x2000..0x2003).collect(&program_memory.method(:read_word))
        expect(ids).to eq [0x3FFF] * 4  # bad
      end

      it "initial value cannot be read by the firmware", flaw: true do
        run_subroutine :readX, cycle_limit: 100
        expect(x.value).to eq 0x3FFF  # bad
      end
    end
    
    it "can be written by Ruby" do
      program_memory[0x2000] = 0x700
      expect(program_memory[0x2000]).to eq 0x700
    end

    it "can be read by the firmware after being written by Ruby" do
      program_memory[0x2000] = 0xA0E
      run_subroutine :readX, cycle_limit: 100
      expect(x.value).to eq 0xA0E
    end
    
    it "can be written by firmware except in MPLAB X 1.85", flaw: true do
      # This flaw was reported and fixed:
      # http://www.microchip.com/forums/m743214.aspx
    
      x.value = 0xE23
      run_subroutine :saveX, cycle_limit: 20000
      
      expected = RPicSim::Flaws[:firmware_cannot_write_user_id0] ? 0x3FFF : 0xE23
      expect(program_memory[0x2000]).to eq expected
    end
  end
  
  context 'in configuration memory space' do
    it 'can read' do
      expect(program_memory[0x2007]).to eq 0x2E06
    end
  end
  
  context 'in device ID space' do
    it 'always reads as all ones', flaw: true do
      expect(program_memory[0x2006]).to eq 0x3FFF
    end
  end
  
end
