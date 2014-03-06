require_relative '../spec_helper'

describe 'NMMRs' do
  before do
    start_sim Firmware::ReadSFR
  end

  describe '#reg' do
    it 'can get WREG on a PIC10F322' do
      expect(reg(:WREG)).to be
    end

    it 'can get STATUS on a PIC10F322' do
      expect(reg(:STATUS)).to be
    end
  end

  describe 'wreg' do
    it 'returns the right register' do
      expect(wreg).to be reg(:WREG)
    end
  end

  describe 'stkptr' do
    it 'returns the right register' do
      expect(stkptr).to be reg(:STKPTR)
    end
  end

end
