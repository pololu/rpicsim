module RPicSim::Mplab
  # This class creates and wraps a com.microchip.mplab.mdbcore.program.interfaces.IProgramFile
  class MplabProgramFile
    EepromRange = 0xF00000..0xFFFFFF

    def initialize(filename, device)
      raise "File does not exist: #{filename}" if !File.exist?(filename)  # Avoid a Java exception.

      if !File.realdirpath(filename).split('/').include?('dist')
        raise 'The file must be inside a directory named dist or else the MCLoader ' \
              'class will throw an exception saying that it cannot find the COF file.'
      end

      factory = Lookup.getDefault.lookup(Mdbcore.program.spi.IProgramFileProviderFactory.java_class)
      @program_file = factory.getProvider(filename, device)
      @program_file.Load
    end

    def symbols
      @symbols ||= Hash[raw_symbols.map { |s| [s.m_Symbol.to_sym, s.address] }]
    end

    def symbols_in_ram
      @symbols_in_ram ||= Hash[
        grouped_symbols[:ram]
          .map { |s| [s.m_Symbol.to_sym, s.address] }
      ]
    end

    def symbols_in_program_memory
      @symbols_in_code_space ||= Hash[
        grouped_symbols[:program_memory]
          .map { |s| [s.m_Symbol.to_sym, s.address] }
      ]
    end

    def symbols_in_eeprom
      @symbols_in_eeprom ||= Hash[
        grouped_symbols[:eeprom]
          .map { |s| [s.m_Symbol.to_sym, s.address - EepromRange.min] }
      ]
    end

    private

    def grouped_symbols
      @grouped_symbols ||= begin
        hash = raw_symbols.group_by(&method(:memory_type))
        hash.default = []
        hash
      end
    end

    # m_lType:  meaning:
    # 0         MPASM RAM
    # 2         XC8 RAM
    # 8         XC8 RAM (SFR bits)
    # 12        XC8 RAM (variables, SFR uint8_t)
    # 14        XC8 program memory variable
    # 22        MPASM program memory or EEPROM
    # 40        XC8 local variable (pointer to a struct?)
    # 44        XC8 local variable
    # 64        XC8 program memory function
    # 65        XC8 program memory function
    # 66        XC8 program memory function
    # 69        XC8 program memory function
    # 76        XC8 program memory function
    # 78        XC8 program memory function
    # 79        XC8 program memory function
    # 81        XC8 program memory function
    # 82        XC8 program memory function
    # 104       XC8 program memory variable (array of unions) (but sometimes in RAM instead)
    # 108       XC8 program memory variable (array)
    # 110       XC8 program memory variable (struct) (but sometimes in RAM instead)
    # 111       XC8 program memory variable (array of uint32_t) (but sometimes it is in RAM instead)
    # 366       XC8 program memory variable (array of pointers)
    #
    # The numbers above are not very well tested and probably incomplete.  This
    # is OK because for XC8 programs people should use the HEX and SYM file
    # instead of the COF file.
    def memory_type(symbol)
      case symbol.m_lType
      when 0, 2, 8, 12, 40, 44, 108
        :ram
      when 22
        EepromRange.include?(symbol.address) ? :eeprom : :program_memory
      when 14, 64, 65, 66, 69, 76, 78, 79, 81, 82, 104, 110, 111, 366
        :program_memory
      else
        :unknown
      end
    end

    # Useful for debugging.
    # Just put this line in your simulation class definition temporarily:
    # pp program_file.instance_variable_get(:@mplab_program_file).send(:symbol_dump).sort
    def symbol_dump
      raw_symbols.map { |s| [s.m_Symbol, s.m_lType, s.address, memory_type(s)] }
    end

    def raw_symbols
      @program_file.getSymbolTable.getSymbols(0, 0)
    end
  end
end
