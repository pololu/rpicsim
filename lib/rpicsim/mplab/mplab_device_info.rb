require_relative 'mplab_sfr_info'
require_relative 'mplab_nmmr_info'

module RPicSim::Mplab
  # DeviceInfo is a wrapper for the MPLAB xPIC class which gives us information
  # about the target PIC device.
  class MplabDeviceInfo
    # Makes a new DeviceInfo object.
    # @param xpic [com.microchip.mplab.crownkingx.xPIC]
    def initialize(xpic)
      @xpic = xpic
    end
  
    def code_word_max_value
      # Assumption: the initial value is the same as the maximum value
      # because all bits start as 1.
      @xpic.getMemTraits.getCodeWordTraits.getInitValue
    end
    
    # The number that a code-space address increases by when you
    # advance to the next word of code space.
    # For PIC18s this is 2.
    # For other architectures this is 1.
    def code_address_increment
      @xpic.getMemTraits.getCodeWordTraits.getAddrInc
    end
    
    def sfrs
      @sfrs ||= @xpic.getAddrOntoSFR.map do |addr, node|
        MplabSfrInfo.new addr, com.microchip.crownking.edc.Register.new(node)
      end
    end
    
    def nmmrs
      @xpic.getIDOntoCoreNMMR.map do |id, node|
        MplabNmmrInfo.new id, com.microchip.crownking.edc.Register.new(node)
      end
    end
  end
end