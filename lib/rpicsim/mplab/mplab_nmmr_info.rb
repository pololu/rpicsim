module RPicSim::Mplab
  class MplabNmmrInfo
    attr_reader :id
  
    # @param id The id of the register.  This is like an address.
    # @param register [com.microchip.crownking.edc.Register]
    def initialize(id, register)
      @id = id
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