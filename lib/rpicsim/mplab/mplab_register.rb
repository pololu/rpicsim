module RPicSim::Mplab
  class MplabRegister
    # @param register [com.microchip.mplab.mdbcore.simulator.Register]
    def initialize(register)
      @register = register
    end
    
    def write(value)
      @register.write(value)
      value
    end
    
    def read
      @register.read
    end
    
    def name
      @register.getName
    end
    
    def address
      @register.getAddress
    end
  end
end