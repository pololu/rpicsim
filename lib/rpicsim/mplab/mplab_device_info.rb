require_relative 'sfr_info'
require_relative 'nmmr_info'

module RPicSim::Mplab
  # DeviceInfo is a wrapper for the MPLAB xPIC class which gives us information
  # about the target PIC device.
  class DeviceInfo
    # Makes a new DeviceInfo object.
    # @param xpic [com.microchip.mplab.crownkingx.xPIC]
    def initialize(xpic)
      @xpic = xpic
    end
  
    def flash_word_max_value
      @xpic.getMemTraits.getCodeWordTraits.getInitValue
    end
    
    def sfrs
      @sfrs ||= @xpic.getAddrOntoSFR.map do |addr, node|
        SfrInfo.new addr, com.microchip.crownking.edc.Register.new(node)
      end
    end
    
    def nmmrs
      @xpic.getIDOntoCoreNMMR.map do |id, node|
        NmmrInfo.new id, com.microchip.crownking.edc.Register.new(node)
      end
    end
  end
end