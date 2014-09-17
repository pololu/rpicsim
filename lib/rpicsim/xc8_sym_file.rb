require 'scanf'

# @api public
module RPicSim
  # This class can be used to load an XC8 sym file and get the information about
  # the symbols in it.  This is useful because the COF file produced by XC8 does
  # not have enough information to identify what memory space every symbol is
  # in.
  #
  # Example usage:
  #
  #     class MySim < RPicSim::Sim
  #       use_device 'PIC18F25K50'
  #       use_file DistDir + 'TestXC8.hex'
  #       import_symbols RPicSim::Xc8SymFile.new(DistDir + 'TestXC8.sym')
  #
  #       # ...
  #     end
  #
  # @api public
  class Xc8SymFile
    # Returns all the symbols.
    # The return value is a hash where the keys are the names of the symbols
    # (represented as Ruby symbols) and the values are the addresses of the symbols.
    #
    # @return [Hash]
    attr_reader :symbols

    # Returns all the symbols in RAM.
    # The return value is a hash where the keys are the names of the symbols
    # (represented as Ruby symbols) and the values are the addresses of the symbols.
    #
    # @return [Hash]
    attr_reader :symbols_in_ram

    # Returns all the symbols in EEPROM.
    # The return value is a hash where the keys are the names of the symbols
    # (represented as Ruby symbols) and the values are the addresses of the symbols.
    #
    # @return [Hash]
    attr_reader :symbols_in_eeprom

    # Returns all the symbols in program memory.
    # The return value is a hash where the keys are the names of the symbols
    # (represented as Ruby symbols) and the values are the addresses of the symbols.
    #
    # @return [Hash]
    attr_reader :symbols_in_program_memory

    # @api private
    attr_reader :symbol_raw_data

    # Creates a new instance of this class containing information from the
    # specified file.
    #
    # @param filename [String]
    # @param opts [Hash] Specified additional options.  The options are:
    #   * +:user_ram_sections+: Array of strings of section names that
    #     should be considered to be in RAM.
    #   * +:user_program_memory_sections+: Array of strings of section names that
    #     should be considered to be in program memory.
    #   * +:user_eeprom_sections+: Array of strings of section names that
    #     should be considered to be in EEPROM.
    def initialize(filename, opts = {})
      @symbols = {}
      @symbols_in_ram = {}
      @symbols_in_eeprom = {}
      @symbols_in_program_memory = {}

      @filename = filename
      @sections_in_ram = %w{ABS BIGRAM COMRAM RAM SFR FARRAM
                            BANK0 BANK1 BANK2 BANK3 BANK4 BANK5 BANK6 BANK7}
      @sections_in_code = %w{CODE CONST IDLOC MEDIUMCONST SMALLCONST}
      @sections_in_eeprom = %w{EEDATA}

      allowed_keys = [:user_ram_sections,
                      :user_program_memory_sections,
                      :user_eeprom_sections,
                      :custom_ram_sections,
                      :custom_code_sections,
                      :custom_eeprom_sections]
      invalid_keys = opts.keys - allowed_keys
      if !invalid_keys.empty?
        raise "Invalid options: #{invalid_keys.inspect}"
      end

      @sections_in_ram += opts.fetch(:user_ram_sections, [])
      @sections_in_code += opts.fetch(:user_program_memory_sections, [])
      @sections_in_eeprom += opts.fetch(:user_eeprom_sections, [])

      # Legacy options introduced in 0.4.0, but deprecated now.
      @sections_in_ram += opts.fetch(:custom_ram_sections, [])
      @sections_in_code += opts.fetch(:custom_code_sections, [])
      @sections_in_eeprom += opts.fetch(:custom_eeprom_sections, [])

      read_data
      sort_data
    end

    private

    def read_data
      @symbol_raw_data = {}
      File.foreach(@filename) do |line|
        entry = line.scanf('%s %x %x %s %x')
        break if entry[0].start_with? '%'
        key = entry[0].to_sym
        entry[0] = key
        @symbol_raw_data[key] = entry
      end
    end

    def sort_data
      @symbol_raw_data.values.each do |name, address, _, section, _|
        @symbols[name] = address

        if @sections_in_ram.include?(section)
          @symbols_in_ram[name] = address
        end

        if @sections_in_code.include?(section)
          @symbols_in_program_memory[name] = address
        end

        if @sections_in_eeprom.include?(section)
          @symbols_in_eeprom[name] = address
        end
      end
    end
  end
end
