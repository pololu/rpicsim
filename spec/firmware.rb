module Firmware
  MpasmDistDir = File.dirname(__FILE__) + '/firmware/mpasm/dist/'

  class Addition < RPicSim::Sim
    use_device 'PIC10F322'
    use_file MpasmDistDir + 'Addition.cof'

    def_var :x, :uint16
    def_var :y, :uint16
    def_var :z, :uint16
  end

  class BoringLoop < RPicSim::Sim
    use_device 'PIC10F322'
    use_file MpasmDistDir + 'BoringLoop.cof'
  end

  class DrivePinHigh < RPicSim::Sim
    use_device 'PIC10F322'
    use_file MpasmDistDir + 'DrivePinHigh.cof'
  end

  class EepromVariables < RPicSim::Sim
    use_device 'PIC18F25K50'
    use_file MpasmDistDir + 'EepromVariables.cof'
    def_var :eepromVar1, :uint8, memory: :eeprom
  end

  class FlashVariables < RPicSim::Sim
    use_device 'PIC10F322'
    use_file MpasmDistDir + 'FlashVariables.cof'
    def_var :x, :uint16

    def_var :normalFlashVar, :word, memory: :program_memory
    def_var :userId0, :word, address: 0x2000, memory: :program_memory
    def_var :userId1, :word, address: 0x2001, memory: :program_memory
    def_var :userId2, :word, address: 0x2002, memory: :program_memory
    def_var :userId3, :word, address: 0x2003, memory: :program_memory
    def_var :flashu16, :uint16, memory: :program_memory
  end

  class LongDelay < RPicSim::Sim
    use_device 'PIC10F322'
    use_file MpasmDistDir + 'LongDelay.cof'
    def_var :hot, :uint8
  end

  class NestedSubroutines < RPicSim::Sim
    use_device 'PIC10F322'
    use_file MpasmDistDir + 'NestedSubroutines.cof'
  end

  class PinMirror < RPicSim::Sim
    use_device 'PIC10F322'
    use_file MpasmDistDir + 'PinMirror.cof'

    def_pin :main_input, :RA0
    def_pin :main_output, :RA1
  end

  class ReadADC < RPicSim::Sim
    use_device 'PIC10F322'
    use_file MpasmDistDir + 'ReadADC.cof'
  end

  class ReadPin < RPicSim::Sim
    use_device 'PIC10F322'
    use_file MpasmDistDir + 'ReadPin.cof'
    def_var :x, :uint8
    def_pin :main_pin, :RA0
  end

  class ReadSFR < RPicSim::Sim
    use_device 'PIC10F322'
    use_file MpasmDistDir + 'ReadSFR.cof'
    def_var :x, :uint8
  end

  class Test10F202 < RPicSim::Sim
    use_device 'PIC10F202'
    use_file MpasmDistDir + 'Test10F202.cof'
  end

  class Test10F322 < RPicSim::Sim
    use_device 'PIC10F322'
    use_file MpasmDistDir + 'Test10F322.cof'
  end

  class Test16F1826 < RPicSim::Sim
    use_device 'PIC16F1826'
    use_file MpasmDistDir + 'Test16F1826.cof'
  end

  class Test18F25K50 < RPicSim::Sim
    use_device 'PIC18F25K50'
    use_file MpasmDistDir + 'Test18F25K50.cof'
    def_var :var1, :uint8
    def_var :var2, :uint16
    def_var :resultVar, :uint16
    def_var :flashVar1, :word, memory: :program_memory
    def_var :flashVar2, :word, memory: :program_memory
    def_var :flashVar3, :uint24, memory: :program_memory
  end

  class Variables < RPicSim::Sim
    use_device 'PIC10F322'
    use_file MpasmDistDir + 'Variables.cof'
    def_var :xu8, :uint8
    def_var :xs8, :int8
    def_var :xu16, :uint16
    def_var :yu16, :uint16
    def_var :zu16, :uint16
    def_var :xs16, :int16
    def_var :xu24, :uint24
    def_var :xs24, :int24
    def_var :xu32, :uint32
    def_var :xs32, :int32
  end

  class WriteTo5F < RPicSim::Sim
    use_device 'PIC10F322'
    use_file MpasmDistDir + 'WriteTo5F.cof'
  end
end
