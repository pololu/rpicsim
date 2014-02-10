module RPicSim::Mplab
  class SfrInfo
    attr_reader :address
  
    # TODO: try to get rid of the address parameter
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