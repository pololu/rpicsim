require_relative 'mplab_register'

module RPicSim::Mplab
  class Processor
    # @param processor [com.microchip.mplab.mdbcore.simulator.Processor]
    def initialize(processor)
      @processor = processor
    end
    
    def get_pc
      @processor.getPC
    end
    
    def set_pc(value)
      @processor.setPC(value)
    end
  end
end