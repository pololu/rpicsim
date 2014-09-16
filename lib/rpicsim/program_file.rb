require_relative 'mplab'
require_relative 'label'
require_relative 'symbol_set'

# TODO: When symbols have the same address, think about how to choose the more
# interesting one in a stack trace (fewer underscores?)

module RPicSim
  # Represents a PIC program file (e.g. COF or HEX).
  # Keeps track of all the symbols loaded from that file and also allows you
  # to add symbols in various ways.
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

      @labels = {}

      @symbol_set = SymbolSet.new
      @symbol_set.def_memory_type :ram
      @symbol_set.def_memory_type :program_memory
      @symbol_set.def_memory_type :eeprom

      @symbol_set.on_symbol_definition do |name, address, memory_type|
        if memory_type == :program_memory
          labels[name] = Label.new(name, address)
        end
      end

      import_symbols @mplab_program_file
    end

    # Imports symbols from an additional symbol source.
    #
    # The +symbol_source+ parameter should be an object that responds to some
    # subset of these methods: +#symbols+, +#symbols_in_ram+,
    # +#symbols_in_program_memory+, +#symbols_in_eeprom+.  The methods should
    # take no arguments and return a hash where the keys are symbol names
    # (represented as Ruby symbols) and the values are addresses (as
    # integers).
    def import_symbols(symbol_source)
      if symbol_source.respond_to?(:symbols)
        @symbol_set.def_symbols symbol_source.symbols
      end

      if symbol_source.respond_to?(:symbols_in_ram)
        @symbol_set.def_symbols symbol_source.symbols_in_ram, :ram
      end

      if symbol_source.respond_to?(:symbols_in_program_memory)
        @symbol_set.def_symbols symbol_source.symbols_in_program_memory, :program_memory
      end

      if symbol_source.respond_to?(:symbols_in_eeprom)
        @symbol_set.def_symbols symbol_source.symbols_in_eeprom, :eeprom
      end
    end

    # Defines a new symbol.
    #
    # @param name [Symbol] The name of the symbol.
    # @param address [Integer] The address of the symbol.
    # @param memory_type [Symbol] (optional) The type of memory the symbol
    #   belongs to.  This should either by +:ram+, +:program_memory+, or
    #   +:eeprom+.
    def def_symbol(name, address, memory_type = nil)
      @symbol_set.def_symbol name, address, memory_type
    end

    # Returns all the symbols known to the simulation.
    #
    # The return value is a hash where the keys are the names of the symbols
    # (represented as Ruby symbols) and the values are the addresses of the symbols.
    #
    # Warning: This is a persistent hash that will automatically be updated when
    # new symbols are defined.
    def symbols
      @symbol_set.symbols
    end

    # Returns all the symbols in RAM.
    # The return value is a hash where the keys are the names of the symbols
    # (represented as Ruby symbols) and the values are the addresses of the symbols.
    #
    # Warning: This is a persistent hash that will automatically be updated when
    # new symbols are defined.
    def symbols_in_ram
      @symbol_set.symbols_in_memory(:ram)
    end

    # Returns all the symbols in program memory.
    # The return value is a hash where the keys are the names of the symbols
    # (represented as Ruby symbols) and the values are the addresses of the symbols.
    #
    # Warning: This is a persistent hash that will automatically be updated when
    # new symbols are defined.
    def symbols_in_program_memory
      @symbol_set.symbols_in_memory(:program_memory)
    end

    # Returns all the symbols in EEPROM.
    # The return value is a hash where the keys are the names of the symbols
    # (represented as Ruby symbols) and the values are the addresses of the symbols.
    #
    # Warning: This is a persistent hash that will automatically be updated when
    # new symbols are defined.
    def symbols_in_eeprom
      @symbol_set.symbols_in_memory(:eeprom)
    end

    # Returns a hash associating program memory label names (as symbols) to their addresses.
    # @return (Hash)
    attr_reader :labels

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
  end
end
