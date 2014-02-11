module RPicSim::Mplab
  class NmmrInfo
    attr_reader :id
  
    # @param address The address of the register.
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