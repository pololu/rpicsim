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
        symbols.select { |s| s.m_lType == 0 }.map { |s| [s.m_Symbol.to_sym, s.address] }
      ]
    end
    
    def symbols_in_program_memory
      @symbols_in_code_space ||= Hash[
        symbols.
          select { |s| s.m_lType != 0 && !EepromRange.include?(s.address) }.
          map { |s| [s.m_Symbol.to_sym, s.address] }
      ]
    end
    
    def symbols_in_eeprom
      @symbols_in_eeprom ||= Hash[
        symbols.
          select { |s| s.m_lType != 0 && EepromRange.include?(s.address) }.
          map { |s| [s.m_Symbol.to_sym, s.address - EepromRange.min] }
      ]    
    end

    private
    
    def symbols
      @program_file.getSymbolTable.getSymbols(0, 0)
    end
  end 
end