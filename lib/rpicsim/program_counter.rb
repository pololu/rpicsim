module RPicSim

  # This little class represents the program counter.  We could have
  # just used 'pc' and 'pc=' methods on the Pic class, but this makes
  # the PC more consistent with the way the WREG and STKPTR are treated.
  class ProgramCounter
    # processor is a com.microchip.mplab.mdbcore.simulator.Processor
    def initialize(processor)
      @processor = processor
    end
    
    def value
      @processor.getPC
    end
    
    def value=(val)
      @processor.setPC(val)
    end
  end
end