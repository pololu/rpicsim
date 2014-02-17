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
      
      @assembly = Mplab::MplabAssembly.new(device)
      @assembly.load_file(filename)
      @address_increment = @assembly.device_info.code_address_increment
      
      @instructions = []
    end
    
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
      mplab_instruction = @assembly.disassembler.disassemble(address)
      
      # Convert the increment, which is the number of bytes, into 'size',
      # which is the same units as the flash address space.
      if @address_increment == 1
        # Non-PIC18 architectures: flash addresses are in terms of words
        # so we devide by two to convert from bytes to words.
        size = mplab_instruction.inc / 2
      elsif @address_increment == 2
        # PIC18 architecture: No change necessary because both are in terms
        # of bytes.
        size = mplab_instruction.inc
      else
        raise "Cannot handle address increment value of #{@address_increment}."
      end

      # TODO: add support for all other 8-bit PIC architectures
      properties = Array case mplab_instruction.opcode
      when 'ADDLW'
      when 'ADDWF'
      when 'ADDWFC'
      when 'ANDLW'
      when 'ANDWF'
      when 'BC'     then [:conditional_relative_branch]
      when 'BCF'
      when 'BN'     then [:conditional_relative_branch]
      when 'BNC'    then [:conditional_relative_branch]
      when 'BNN'    then [:conditional_relative_branch]
      when 'BNOV'   then [:conditional_relative_branch]
      when 'BNZ'    then [:conditional_relative_branch]
      when 'BRA'    then [:conditional_relative_branch]
      when 'BSF'
      when 'BTG'
      when 'BTFSC'  then [:conditional_skip]
      when 'BTFSS'  then [:conditional_skip]
      when 'BZ'     then [:conditional_relative_branch]
      when 'CALL'   then [:call]
      when 'CPFSEQ' then [:conditional_skip]
      when 'CPFSGT' then [:conditional_skip]
      when 'CPFSLT' then [:conditional_skip]
      when 'CLRF'
      when 'CLRW'
      when 'CLRWDT'
      when 'COMF'
      when 'DAW'
      when 'DECF'
      when 'DECFSZ' then [:conditional_skip]
      when 'DCFSNZ' then
      when 'GOTO'   then [:goto]
      when 'INCF'
      when 'INCFSZ' then [:conditional_skip]
      when 'INFSNZ' then [:conditional_skip]
      when 'IORLW'
      when 'IORWF'
      when 'LFSR'
      when 'MOVLB'
      when 'MOVLW'
      when 'MOVWF'
      when 'MOVF'
      when 'MOVFF'
      when 'MULLW'
      when 'MULWF'
      when 'NEGF'
      when 'NOP'
      when 'OPTION'
      when 'PUSH'
      when 'POP'
      when 'RCALL'  then [:relative_call]
      when 'RESET'  then [:control_ender]
      when 'RETFIE' then [:control_ender]
      when 'RETLW'  then [:control_ender]
      when 'RETURN' then [:control_ender]
      when 'RLCF'
      when 'RLF'
      when 'RLNCF'
      when 'RRCF'
      when 'RRF'
      when 'RRNCF'
      when 'SETF'
      when 'SLEEP'
      when 'SUBLW'
      when 'SUBWF'
      when 'SUBWFB'
      when 'SWAPF'
      when 'TBLRD*'
      when 'TBLRD*+'
      when 'TBLRD*-'
      when 'TBLRD+*'
      when 'TBLWT*'
      when 'TBLWT*+'
      when 'TBLWT*-'
      when 'TBLWT+*'
      when 'TRIS'
      when 'TSTFSZ' then [:conditional_skip]
      when 'XORLW'
      when 'XORWF'      
      else
        raise "Unrecognized opcode #{mplab_instruction.opcode} " +
          "(#{address_description(address)}, operands #{mplab_instruction.operands.inspect})."
      end
      
      Instruction.new(address, self, mplab_instruction.opcode,
        mplab_instruction.operands, size, @address_increment,
        mplab_instruction.instruction_string, properties)
    end
  end
end