module RPicSim::Mplab
  class MplabSfrInfo
    attr_reader :address
  
    # @param address The address of the register.
    # @param register [com.microchip.crownking.edc.Register]
    def initialize(address, register)
      @address = address
      @register = register
    end
    
    # Returns how many bits the register has.
    def width
      @register.width
    end
    
    def name
      @register.name
    end
  end
end