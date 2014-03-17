module RPicSim::Mplab
  # This class creates and wraps a com.microchip.mplab.mdbcore.program.interfaces.IProgramFile
  class MplabProgramFile
    EepromRange = 0xF00000..0xFFFFFF

    def initialize(filename, device)
      raise "File does not exist: #{filename}" if !File.exist?(filename)  # Avoid a Java exception.

      if !File.realdirpath(filename).split('/').include?('dist')
        raise 'The file must be inside a directory named dist or else the MCLoader ' +
              'class will throw an exception saying that it cannot find the COF file.'
      end

      factory = Lookup.getDefault.lookup(Mdbcore.program.spi.IProgramFileProviderFactory.java_class)
      @program_file = factory.getProvider(filename, device)
      @program_file.Load
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
        hash = symbols.group_by(&method(:memory_type))
        hash.default = []
        hash
      end
    end

    # m_lType:  meaning:
    # 0         MPASM RAM
    # 12        XC8 RAM
    # 22        MPASM program memory or EEPROM
    # 14        XC8 program memory variable
    # 65        XC8 program memory function

    def memory_type(symbol)
      case symbol.m_lType
      when 0, 12
        :ram
      when 22
        EepromRange.include?(symbol.address) ? :eeprom : :program_memory
      when 12
        :ram
      when 14, 65
        :program_memory
      else
        raise "Unknown m_lType #{symbol.m_lType} for symbol #{symbol.name}."
      end
    end

    # Useful for debugging.
    # Just put this line in your simulation class definition temporarily:
    # pp program_file.instance_variable_get(:@mplab_program_file).send(:symbol_dump)
    def symbol_dump
      symbols.map { |s| [s.m_Symbol, s.m_lType, s.address, memory_type(s)] }
    end

    def symbols
      @program_file.getSymbolTable.getSymbols(0, 0)
    end
  end
end
