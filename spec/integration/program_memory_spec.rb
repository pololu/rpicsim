require_relative '../spec_helper'

describe 'RPicSim::Sim#program_memory' do
  before do
    start_sim Firmware::FlashVariables
  end
  
  context 'normal space (not user id space)' do
    let(:address) { program_file.label(:normalFlashVar).address }
    
    before do
      run_subroutine :setupNormalFlash, cycle_limit: 100
    end
    
    describe '#read_byte' do
      it 'works (can read default value), but takes a word address so it can only read the LSB of every word' do
        expect(program_memory.read_byte(address)).to eq 0x01
      end
    end

    describe '#write_byte' do
      it 'works (affects read_byte)' do
        program_memory.write_byte(address, 0x89)
        expect(program_memory.read_byte(address)).to eq 0x89
      end
      
      it 'does not affect the upper bits of the word' do
        # This is useful; if you have a ROM variable stored with RETLWs
        # then it will continue to have RETLWs after you write to its bytes.
        # If you have a ROM variable stored with zeroes in the upper bits, that
        # will remain the same too.
        program_memory.write_byte(address, 0xA2)
        expect(program_memory.read_word(address)).to eq 0x8A2      
      end
    end
    
    describe '#read_word' do
      it 'can read the default value' do
        expect(program_memory.read_word(address)).to eq 0x801
      end

      it 'can read the value written by the firmware' do
        x.value = 0xE23
        run_subroutine :saveX, cycle_limit: 20000
        expect(program_memory.read_word(address)).to eq 0xE23
      end
    end
    
    describe '#write_word' do
      it 'affects the value read by read_word' do
        program_memory.write_word(address, 0x700)
        expect(program_memory.read_word(address)).to eq 0x700
      end
      
      it 'affects the value read by the firmware' do
        program_memory.write_word(address, 0xA0E)
        run_subroutine :readX, cycle_limit: 100
        expect(x.value).to eq 0xA0E
      end
    end

  end
  
  context 'in user id space' do
    before do
      run_subroutine :setupUserId0, cycle_limit: 100
    end

    describe 'does not get loaded correctly from COF file', flaw: true do
      # The workaround is to simply set the flash variables to the correct values from Ruby
      # and we have tests below to prove that works.
    
      it 'initial value cannot be read by Ruby', flaw: true do
        ids = (0x2000..0x2003).collect(&program_memory.method(:read_word))
        expect(ids).to eq [0x3FFF] * 4  # bad
      end

      it 'initial value cannot be read by the firmware', flaw: true do
        run_subroutine :readX, cycle_limit: 100
        expect(x.value).to eq 0x3FFF  # bad
      end
    end
    
    describe '#write_word' do
      it 'works (affects read_word)' do
        program_memory.write_word(0x2000, 0x700)
        expect(program_memory.read_word(0x2000)).to eq 0x700
      end

      it 'can be read by the firmware after being written by Ruby' do
        program_memory.write_word(0x2000, 0xA0E)
        run_subroutine :readX, cycle_limit: 100
        expect(x.value).to eq 0xA0E
      end
    end
    
    it 'can be written by firmware except in MPLAB X 1.85', flaw: true do
      # This flaw was reported and fixed:
      # http://www.microchip.com/forums/m743214.aspx
    
      x.value = 0xE23
      run_subroutine :saveX, cycle_limit: 20000
      
      expected = RPicSim::Flaws[:firmware_cannot_write_user_id0] ? 0x3FFF : 0xE23
      expect(program_memory.read_word(0x2000)).to eq expected
    end
  end
  
  context 'in configuration memory space' do
    it 'can read' do
      expect(program_memory.read_word(0x2007)).to eq 0x2E06
    end
  end
  
  context 'in device ID space' do
    it 'always reads as all ones', flaw: true do
      expect(program_memory.read_word(0x2006)).to eq 0x3FFF
    end
  end
  
end

describe 'RPicSim::Sim#program_memory for a PIC18' do
  before do
    start_sim Firmware::Test18F25K50
  end

  describe '#read_word' do
    # This test ensures that part of the comment we have in memory.rb is true.
    it 'uses byte addresses but reads and writes 16-bit words' do
      expect(program_memory.read_word(0x20)).to eq 0xCC33  # read the value of flashVar1
    end
    
    it 'allows unaligned reads' do
      expect(program_memory.read_word(0x21)).to eq 0x11CC  # read part of flashVar1 and flashVar2 
    end
  end
  
  describe '#read_byte' do
    it 'can read bytes one at a time and interprets them as unsigned' do
      expect(program_memory.read_byte(0x20)).to eq 0x33
      expect(program_memory.read_byte(0x21)).to eq 0xCC  # ensures unsigned interpretation
      expect(program_memory.read_byte(0x22)).to eq 0x11
    end    
  end

  describe '#write_byte' do
    it 'can write bytes one at a time and interprets them as unsigned' do
      program_memory.write_byte(0x22, 0x90)
      expect(program_memory.read_byte(0x22)).to eq 0x90
    end
    
    it 'does not change the other upper byte of the word' do
      program_memory.write_byte(0x22, 0x90)
      expect(program_memory.read_byte(0x23)).to eq 0x22  # doesn't change the other byte in the word      
    end
  end
  
end