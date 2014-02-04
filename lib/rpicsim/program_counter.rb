module RPicSim

  # Instances of this class represent the program counter in a
  # simulated microcontroller.
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