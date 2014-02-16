module RPicSim::Mplab
  class MplabInstruction
    # @param instruction [com.microchip.mplab.mdbcore.disasm.Instruction]
    def initialize(instruction)
      @instruction = instruction
    end
    
    def opcode
      # TODO: maybe make opcode be a symbol too, since the field names are
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
    def operands_hash(map)
      operands = convert_map_to_hash(map)
      fix_signed_fields(operands)
      operands
    end
    
    def convert_map_to_hash(map)
      # Convert from Map<String, Integer> to a Ruby hash
      # with symbols as keys instead of strings.    
      operands = {}
      map.each do |operand_name, value|
        operands[operand_name.to_sym] = value
      end
      operands
    end

    # Warning: This mutates the supplied hash.
    def fix_signed_fields(operands)
      case opcode
      when 'BC', 'BN', 'BNC', 'BNN', 'BNOV', 'BNZ', 'BOV', 'BZ'
        operands[:n] = convert_unsigned_to_signed(operands[:n], 8)
      when 'BRA', 'RCALL'
        operands[:n] = convert_unsigned_to_signed(operands[:n], 11)
      end
      
      operands
    end
    
    def convert_unsigned_to_signed(unsigned, bits)
      if unsigned >= (1 << (bits - 1))
        unsigned - (1 << bits)
      else
        unsigned
      end
    end
  end
end