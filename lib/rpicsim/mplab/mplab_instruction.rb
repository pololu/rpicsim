module RPicSim::Mplab
  # This class wraps a com.microchip.mplab.mdbcore.disasm.Instruction, which
  # represents a disassembled instruction from Microchip's disassembler.
  class MplabInstruction
    attr_reader :opcode

    # @param instruction [com.microchip.mplab.mdbcore.disasm.Instruction]
    def initialize(instruction)
      @instruction = instruction

      @opcode = @instruction.opcode
      @string = @instruction.instruction

      # Fix a typo in MPLAB X.
      if @opcode == 'RBLRD+*'
        @opcode = 'TBLRD+*'
        @string = @string.gsub('RBLRD', 'TBLRD')
      end
      @opcode.freeze
    end

    def instruction_string
      @string
    end

    def operands
      @operands ||= operands_hash(@instruction.operands)
    end

    # Returns the size of the instruction in the same units that are used
    # for program memory addresses.  (Bytes for the PIC18, otherwise words.)
    # @param address_increment The number of address units per word of
    #   program memory in this architecture.  See {MplabDeviceInfo#code_address_increment}.
    def compute_size(address_increment)
      if RPicSim::Flaws[:instruction_inc_is_in_byte_units]
        # Convert the increment, which is the number of bytes, into 'size',
        # which is the same units as the program memory address space.
        if address_increment == 1
          # Non-PIC18 architectures: program memory addresses are in terms of words
          # so we divide by two to convert from bytes to words.
          @instruction.inc / 2
        elsif address_increment == 2
          # PIC18 architecture: No change necessary because both are in terms
          # of bytes.
          @instruction.inc
        else
          raise "Cannot handle address increment value of #{@address_increment}."
        end
      else
        # inc is in the same units as the code space addresses.
        @instruction.inc
      end
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
