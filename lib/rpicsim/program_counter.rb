module RPicSim

  # Instances of this class represent the program counter in a
  # simulated microcontroller.
  class ProgramCounter
    # @param processor [Mplab::Processor]
    def initialize(processor)
      @processor = processor
    end

    def value
      @processor.get_pc
    end

    def value=(val)
      @processor.set_pc(val)
    end
  end
end