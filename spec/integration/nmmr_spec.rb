require 'spec_helper'

describe "NMMRs" do
  before do
    start_sim Firmware::ReadSFR
  end

  describe "nmmr" do
    it "can get WREG on a PIC10F322" do
      expect(nmmr(:WREG)).inspect == ""
    end
  end

  describe "sfr_or_nmmr" do
    it "can get WREG on a PIC10F322" do
      expect(sfr_or_nmmr(:WREG)).inspect == ""
    end

    it "can get STATUS on a PIC10F322" do
      expect(sfr_or_nmmr(:STATUS)).to equal sfr(:STATUS)
    end
  end

  describe "wreg" do
    it "returns the right register" do
      expect(wreg).to equal nmmr(:WREG)
    end
  end

  describe "stkptr" do
    it "returns the right register" do
      expect(stkptr).to equal nmmr(:STKPTR)
    end
  end

end