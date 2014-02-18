module Firmware
  Dir = File.dirname(__FILE__) + "/firmware/dist/"

  class Addition < RPicSim::Sim
    device_is "PIC10F322"
    filename_is Dir + "addition.cof"  # TODO: rename files to Addition
    def_var :x, :u16
    def_var :y, :u16
    def_var :z, :u16
  end

  class BoringLoop < RPicSim::Sim
    device_is "PIC10F322"
    filename_is Dir + "BoringLoop.cof"
  end

  class DrivePinHigh < RPicSim::Sim
    device_is "PIC10F322"
    filename_is Dir + "DrivePinHigh.cof"
  end

  class FlashVariables < RPicSim::Sim
    device_is "PIC10F322"
    filename_is Dir + "FlashVariables.cof"
    def_var :x, :u16
    def_flash_var :normalFlashVar, :word
    def_flash_var :userId0, :word, address: 0x2000
    def_flash_var :userId1, :word, address: 0x2001
    def_flash_var :userId2, :word, address: 0x2002
    def_flash_var :userId3, :word, address: 0x2003
  end

  class LongDelay < RPicSim::Sim
    device_is "PIC10F322"
    filename_is Dir + "LongDelay.cof"
    def_var :hot, :u8
  end

  class NestedSubroutines < RPicSim::Sim
    device_is "PIC10F322"
    filename_is Dir + "NestedSubroutines.cof"
  end

  class PinMirror < RPicSim::Sim
    device_is "PIC10F322"
    filename_is Dir + "PinMirror.cof"

    def_pin :main_input, :RA0
    def_pin :main_output, :RA1
  end

  class ReadADC < RPicSim::Sim
    device_is "PIC10F322"
    filename_is Dir + "ReadADC.cof"
  end

  class ReadPin < RPicSim::Sim
    device_is "PIC10F322"
    filename_is Dir + "ReadPin.cof"
    def_var :x, :u8
    def_pin :main_pin, :RA0
  end

  class ReadSFR < RPicSim::Sim
    device_is "PIC10F322"
    filename_is Dir + "ReadSFR.cof"
    def_var :x, :u8
  end

  class Test10F202 < RPicSim::Sim
    device_is 'PIC10F202'
    filename_is Dir + 'Test10F202.cof'
  end
  
  class Test10F322 < RPicSim::Sim
    device_is 'PIC10F322'
    filename_is Dir + 'Test10F322.cof'
  end

  class Test18F25K50 < RPicSim::Sim
    device_is 'PIC18F25K50'
    filename_is Dir + 'Test18F25K50.cof'
    def_var :var1, :u8
    def_var :var2, :u16
    def_var :resultVar, :u16
    def_flash_var :flashVar1, :word
    def_flash_var :flashVar2, :word
  end

  class Variables < RPicSim::Sim
    device_is "PIC10F322"
    filename_is Dir + "Variables.cof"
    def_var :xu8, :u8
    def_var :xs8, :s8
    def_var :xu16, :u16
    def_var :yu16, :u16
    def_var :zu16, :u16
    def_var :xs16, :s16
    def_var :xu24, :u24
    def_var :xs24, :s24
    def_var :xu32, :u32
    def_var :xs32, :s32
  end

  class WriteTo5F < RPicSim::Sim
    device_is "PIC10F322"
    filename_is Dir + "WriteTo5F.cof"
  end

end