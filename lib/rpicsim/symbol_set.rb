module RPicSim
  # This class is used internally by {Sim} to manage the symbols from the
  # simulated firmware's symbol table..
  class SymbolSet
    def initialize
      @memory_types = []
      @symbols = {}
      @symbols_for_memory = {}
    end

    def def_memory_type(name)
      name = name.to_sym
      @memory_types << name
      @symbols_for_memory[name] = {}
    end

    def def_symbol(name, address, memory_type = nil)
      name = name.to_sym
      address = address.to_i
      if memory_type
        hash = @symbols_for_memory[memory_type.to_sym]
        raise "Invalid memory type: #{memory_type}." if !hash
        hash[name] = address
      end

      @symbols[name] = address
    end

    def def_symbols(symbols, memory_type = nil)
      symbols.each do |name, address|
        def_symbol name, address, memory_type
      end
    end

    def symbols
      @symbols
    end

    def symbols_in_memory(memory_type)
      @symbols_for_memory[memory_type.to_sym]
    end
  end
end
