module RPicSim
  # Instances of this class represent the program counter in a
  # simulated microcontroller.
  # @api public
  class ProgramCounter
    # @param processor [Mplab::Processor]
    def initialize(processor)
      @processor = processor
    end

    # @return [Integer]
    def value
      @processor.get_pc
    end

    # @param val [Integer]
    def value=(val)
      @processor.set_pc(val)
    end
  end
end
