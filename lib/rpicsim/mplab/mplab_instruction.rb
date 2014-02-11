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
      @operands ||= operands_hash(@instruction.operands)
    end
    
    # This seems to be the number of bytes that the instruction takes.
    def inc
      @instruction.inc
    end
    
    private
    def operands_hash(map)
      # Convert from Map<String, Integer> to a Ruby hash.
      # TODO: use symbols for keys instead of strings
      map.to_hash
    end
  end
end