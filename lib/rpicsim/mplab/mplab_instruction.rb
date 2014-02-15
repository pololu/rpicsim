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
    
    # The number of bytes that the instruction takes.
    def inc
      @instruction.inc
    end
    
    private
    # Convert from Map<String, Integer> to a Ruby hash
    # with symbols as keys instead of strings.
    def operands_hash(map)
      operands = {}
      map.each do |operand_name, value|
        operands[operand_name.to_sym] = value
      end
      operands
    end
  end
end