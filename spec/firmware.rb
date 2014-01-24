module Firmware
  Dir = File.dirname(__FILE__) + "/firmware/dist/"

  class Addition < RPicSim::Pic
    device_is "PIC10F322"
    filename_is Dir + "addition.cof"  # TODO: rename files to Addition
    def_var :x, :u16
    def_var :y, :u16
    def_var :z, :u16
  end

  class BoringLoop < RPicSim::Pic
    device_is "PIC10F322"
    filename_is Dir + "BoringLoop.cof"
  end

  class DrivePinHigh < RPicSim::Pic
    device_is "PIC10F322"
    filename_is Dir + "DrivePinHigh.cof"
  end

  class FlashVariables < RPicSim::Pic
    device_is "PIC10F322"
    filename_is Dir + "FlashVariables.cof"
    def_var :x, :u16
    def_flash_var :normalFlashVar, :word
    def_flash_var :userId0, :word, address: 0x2000
    def_flash_var :userId1, :word, address: 0x2001
    def_flash_var :userId2, :word, address: 0x2002
    def_flash_var :userId3, :word, address: 0x2003
  end

  class LongDelay < RPicSim::Pic
    device_is "PIC10F322"
    filename_is Dir + "LongDelay.cof"
    def_var :hot, :u8
  end

  class NestedSubroutines < RPicSim::Pic
    device_is "PIC10F322"
    filename_is Dir + "NestedSubroutines.cof"
  end

  class PinMirror < RPicSim::Pic
    device_is "PIC10F322"
    filename_is Dir + "PinMirror.cof"

    def_pin :main_input, :RA0
    def_pin :main_output, :RA1
  end

  class ReadADC < RPicSim::Pic
    device_is "PIC10F322"
    filename_is Dir + "ReadADC.cof"
  end

  class ReadPin < RPicSim::Pic
    device_is "PIC10F322"
    filename_is Dir + "ReadPin.cof"
    def_var :x, :u8
    def_pin :main_pin, :RA0
  end

  class ReadSFR < RPicSim::Pic
    device_is "PIC10F322"
    filename_is Dir + "ReadSFR.cof"
    def_var :x, :u8
  end

  class Variables < RPicSim::Pic
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

  class WriteTo5F < RPicSim::Pic
    device_is "PIC10F322"
    filename_is Dir + "WriteTo5F.cof"
  end

end