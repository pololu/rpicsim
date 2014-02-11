module RPicSim::Mplab
  class MplabInstruction
    # @param instruction [com.microchip.mplab.mdbcore.disasm.Instruction]
    def initialize(instruction)
      @instruction = instruction
    end
    
    def opcode
      @instruction.opcode
    end
    
    def instruction_string
      @instruction.instruction
    end
    
    def operands
      # Convert from Map<String, Integer> to a Ruby hash.
      @operands ||= @instruction.operands.to_hash
    end
    
    # This seems to be the number of bytes that the instruction takes.
    def inc
      @instruction.inc
    end
  end
end