require_relative '../spec_helper'

describe "Simulated ADC for midrange PICs" do
  before do
    start_sim Firmware::ReadADC
  end
  
  context "when the pin has not been set" do
    it "reads 0" do
      run_subroutine :ReadADC, cycle_limit: 1000
      sfr(:ADRES).value.should == 0
    end
  end

  context "when the pin has been set to low" do
    before do
      pin(:RA1).set(false)
      run_subroutine :ReadADC, cycle_limit: 1000
    end
  
    it "reads 0", flaw: true do
      sfr(:ADRES).value.should == 0
    end
  end
  
  context "when the pin has been set to high" do
    before do
      pin(:RA1).set(true)
      run_subroutine :ReadADC, cycle_limit: 1000
    end
  
    if RPicSim::Flaws[:adc_midrange] == :bad_modulus
      it "reads 0", flaw: true do
        sfr(:ADRES).value.should == 0
      end
    else
      it "reads 255" do
        sfr(:ADRES).value.should == 255
      end
    end
  end
  
  context "when the pin has been set to 0 V" do
    before do
      pin(:RA1).set(0.0)
      run_subroutine :ReadADC, cycle_limit: 1000    
    end
    
    it "reads 0", flaw: true do
      sfr(:ADRES).value.should == 0
    end
  end  
  
  context "when the pin has been set to 0.1 V" do
    before do
      pin(:RA1).set(0.1)
      run_subroutine :ReadADC, cycle_limit: 1000    
    end
    
    if RPicSim::Flaws[:adc_midrange] == :no_middle_values
      it "reads 255", flaw: true do
        sfr(:ADRES).value.should == 255
      end
    else
      it "reads 5" do
        sfr(:ADRES).value.should == 5
      end    
    end
  end  
  
  context "when the pin has been set to 2.5 V" do
    before do
      pin(:RA1).set(2.5)
      run_subroutine :ReadADC, cycle_limit: 1000    
    end
    
    if RPicSim::Flaws[:adc_midrange] == :no_middle_values
      it "reads 255", flaw: true do
        sfr(:ADRES).value.should == 255
      end
    else
      it "reads 128" do
        sfr(:ADRES).value.should == 128
      end    
    end
  end
  
  context "when the pin has been set to 7.5 V" do
    before do
      pin(:RA1).set(7.5)
      run_subroutine :ReadADC, cycle_limit: 1000
    end
  
    if RPicSim::Flaws[:adc_midrange] == :bad_modulus
      it "reads 128", flaw: true do
        sfr(:ADRES).value.should == 128
      end
    else
      it "reads 255" do
        sfr(:ADRES).value.should == 255      
      end
    end
  end
end
