require_relative 'mplab'
require_relative 'label'
require_relative 'instruction'

module RPicSim
  # Represents a PIC program file (e.g. COF or HEX).
  class ProgramFile
    attr_reader :filename
    attr_reader :device
  
    # @param filename [String] The path to the program file.
    # @param device [String] The name of the device the file is for (e.g. "PIC10F322").
    def initialize(filename, device)
      @filename = filename
      @device = device
      @mplab_program_file = Mplab::MplabProgramFile.new(filename, device)
      @instructions = []
    end
    
    private
    def assembly
      @assembly ||= begin
        assembly = Mplab::MplabAssembly.new(device)
        assembly.load_file(filename)
        assembly
      end
    end
    
    def disasm
      @disasm ||= assembly.disasm
    end
    
    public
    # Returns a hash associating RAM variable names (as symbols) to their addresses.
    # @return (Hash)
    def var_addresses
      @var_addresses ||= @mplab_program_file.symbols_in_ram
    end
    
    # Returns a hash associating program memory label names (as symbols) to their addresses.
    # @return (Hash)
    def labels
      @labels ||= begin
        hash = {}
        @mplab_program_file.symbols_in_code_space.each do |name, address|
          hash[name] = Label.new(name, address)
        end
        hash
      end
    end

    # Returns a {Label} object if a program label by that name is found.
    # The name is specified in the code that defined the label.  If you are using a C compiler,
    # you will probably need to prefix the name with an underscore.
    # @return [Label]
    def label(name)
      name = name.to_sym
      label = labels[name]
      if !label
        raise ArgumentError, message_for_label_not_found(name)
      end
      return label
    end

    # Generates a friendly human-readable string description of the given address in
    # program memory.
    # @param address [Integer] An address in program memory.
    # @return [String]
    def address_description(address)
      desc = address < 0 ? address.to_s : ("0x%04x" % [address])
      reference_points = labels.values.reject { |label| label.address > address }
      label = reference_points.max_by &:address
      
      if label
        offset = address - label.address
        desc << " = " + label.name.to_s
        desc << "+%#x" % [offset] if offset != 0
      end
      
      return desc
    end
    
    # Gets an {Instruction} object representing the PIC instruction at the given
    # address in program memory.
    # @param address [Integer]
    # @return [Instruction]
    def instruction(address)
      @instructions[address] ||= make_instruction(address)
    end
    
    private
    def message_for_label_not_found(name)
      message = "Cannot find label named '#{name}'."

      maybe_intended_labels = labels.keys.select do |label_sym|
        name.to_s.start_with?(label_sym.to_s)
      end
      if !maybe_intended_labels.empty?
        message << "  MPASM truncates labels.  You might have meant: " +
                   maybe_intended_labels.join(", ") + "."
      end
      message
    end

    def make_instruction(address)
      mc_instruction = disasm.Disassemble(address, nil, nil)

      increment = mc_instruction.inc / 2   # I am not sure if this is right in all cases

      # TODO: add support for all other 8-bit PIC architectures
      properties = Array case mc_instruction.opcode
      when 'ADDWF'
      when 'ANDWF'
      when 'CLRF'
      when 'CLRW'
      when 'COMF'
      when 'DECF'
      when 'DECFSZ' then [:conditional_skip]
      when 'INCF'
      when 'INCFSZ' then [:conditional_skip]
      when 'IORWF'
      when 'MOVWF'
      when 'MOVF'
      when 'NOP'
      when 'RLF'
      when 'RRF'
      when 'SUBWF'
      when 'SWAPF'
      when 'XORWF'
      when 'BCF'
      when 'BSF'
      when 'BTFSC'  then [:conditional_skip]
      when 'BTFSS'  then [:conditional_skip]
      when 'ADDLW'
      when 'ANDLW'
      when 'CALL'   then [:call]
      when 'CLRWDT'
      when 'GOTO'   then [:goto]
      when 'IORLW'
      when 'MOVLW'
      when 'RETFIE' then [:return]
      when 'RETLW'  then [:return]
      when 'RETURN' then [:return]
      when 'SLEEP'
      when 'XORLW'
      else
        raise "Unrecognized opcode #{opcode} (operands #{operands.inspect})."
      end
      
      Instruction.new(address, self, mc_instruction.opcode,
        mc_instruction.operands.to_hash, increment, mc_instruction.instruction,
        properties)
    end
  end
end