require_relative 'mplab'
require_relative 'label'
require_relative 'instruction'

# TODO: interface for adding labels and/or symbols from other sources because
# sometimes the COF file is inadequate.  When symbols have the same address,
# think about how to choose the more interesting one in a stack trace (fewer underscores?)

module RPicSim
  # Represents a PIC program file (e.g. COF or HEX).
  class ProgramFile
    attr_reader :filename
    attr_reader :device

    attr_reader :address_increment

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
    def symbols_in_ram
      @mplab_program_file.symbols_in_ram
    end

    # Returns a hash associating program memory symbol names (as Ruby symbols)
    # to their addresses.
    # @return (Hash)
    def symbols_in_program_memory
      @mplab_program_file.symbols_in_program_memory
    end

    # Returns a hash associating EEPROM memory symbol names (as Ruby symbols)
    # to their addresses.
    # @return (Hash)
    def symbols_in_eeprom
      @mplab_program_file.symbols_in_eeprom
    end

    # Returns a hash associating program memory label names (as symbols) to their addresses.
    # @return (Hash)
    def labels
      @labels ||= begin
        hash = {}
        symbols_in_program_memory.each do |name, address|
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
      label
    end

    # Generates a friendly human-readable string description of the given address in
    # program memory.
    # @param address [Integer] An address in program memory.
    # @return [String]
    def address_description(address)
      desc = address < 0 ? address.to_s : ('0x%04x' % [address])
      reference_points = labels.values.reject { |label| label.address > address }
      label = reference_points.max_by(&:address)

      if label
        offset = address - label.address
        desc << ' = ' + label.name.to_s
        desc << '+%#x' % [offset] if offset != 0
      end

      desc
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
        message << '  MPASM truncates labels.  You might have meant: ' +
                   maybe_intended_labels.join(', ') + '.'
      end
      message
    end

    def make_instruction(address)
      mplab_instruction = @assembly.disassembler.disassemble(address)
      Instruction.new(mplab_instruction, address, @address_increment, self)
    end
  end
end
