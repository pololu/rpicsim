require 'scanf'

module RPicSim
  class Xc8SymFile
    attr_reader :symbols
    attr_reader :symbols_in_ram
    attr_reader :symbols_in_eeprom
    attr_reader :symbols_in_program_memory

    attr_reader :symbol_raw_data

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

      allowed_keys = [:custom_ram_sections,
                      :custom_code_sections,
                      :custom_eeprom_sections]
      invalid_keys = opts.keys - allowed_keys
      if !invalid_keys.empty?
        raise "Invalid options: #{invalid_keys.inspect}"
      end

      if opts[:custom_ram_sections]
        @sections_in_ram += opts[:custom_ram_sections]
      end

      if opts[:custom_code_sections]
        @sections_in_code += opts[:custom_code_sections]
      end

      if opts[:custom_eeprom_sections]
        @sections_in_eeprom += opts[:custom_eeprom_sections]
      end

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
