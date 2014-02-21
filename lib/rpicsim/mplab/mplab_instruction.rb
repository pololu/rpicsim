module RPicSim::Mplab
  class MplabInstruction
    # @param instruction [com.microchip.mplab.mdbcore.disasm.Instruction]
    def initialize(instruction)
      @instruction = instruction
      
      @opcode = @instruction.opcode
      @string = @instruction.instruction
      
      # Fix a typo in MPLAB X.
      if @opcode == 'RBLRD+*'  # TODO: reproduce this as an MPLAB X bug and report to Microchip
        @opcode = 'TBLRD+*'
        @string = @string.gsub('RBLRD', 'TBLRD')
      end
    end
    
    def opcode
      # TODO: maybe make opcode be a symbol too, since the field names are
      @opcode
    end
    
    def instruction_string
      @string
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
        convert_if_present(operands, :n, 8)   # PIC18
      when 'RCALL'
        convert_if_present(operands, :n, 11)  # PIC18
      when 'BRA'
        convert_if_present(operands, :n, 11)  # PIC18
        convert_if_present(operands, :k, 9)   # enhanced midrange
      when 'ADDFSR'
        convert_if_present(operands, :k, 6)   # enhanced midrange
      end
      
      operands
    end

    def convert_if_present(operands, name, bits)
      operands[name] = convert_unsigned_to_signed(operands[name], bits) if operands[name]
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