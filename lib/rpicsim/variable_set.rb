require_relative 'storage/memory_integer'
require_relative 'variable'

module RPicSim
  # This class is used internally by {Sim} to manage user-defined variables.
  class VariableSet
    attr_writer :address_increment

    def initialize
      @memory_types = []
      @symbols_for_memory = {}
      @vars_for_memory = {}
      @vars_for_memory_by_address = {}
    end

    def def_memory_type(name, symbols)
      name = name.to_sym
      @memory_types << name
      @symbols_for_memory[name] = symbols
      @vars_for_memory[name] = {}
      @vars_for_memory_by_address[name] = {}
    end

    def def_var(name, type, opts={})
      allowed_keys = [:memory, :symbol, :address]
      invalid_keys = opts.keys - allowed_keys
      if !invalid_keys.empty?
        raise ArgumentError, "Unrecognized options: #{invalid_keys.join(', ')}"
      end

      name = name.to_sym

      memory_type = opts.fetch(:memory, :ram)
      if !@memory_types.include?(memory_type)
        raise "Invalid memory type '#{memory_type.inspect}'."
      end

      symbol_addresses = @symbols_for_memory[memory_type]

      if opts[:address]
        address = opts[:address].to_i
      else
        symbol = (opts[:symbol] || name).to_sym
        if symbol.to_s.include?('@')
          raise 'Limitations in MPLAB X code prevent us from accessing ' +
            "variables with '@' in the name like '#{symbol}'"
        end
        address = symbol_addresses[symbol] or raise ArgumentError, "Cannot find variable in #{memory_type} named '#{symbol}'."
      end

      klass = case type
              when Class then type
              when :word then Storage::MemoryWord
              when :uint8 then Storage::MemoryUInt8
              when :int8 then Storage::MemoryInt8
              when :uint16 then Storage::MemoryUInt16
              when :int16 then Storage::MemoryInt16
              when :uint24 then Storage::MemoryUInt24
              when :int24 then Storage::MemoryInt24
              when :uint32 then Storage::MemoryUInt32
              when :int32 then Storage::MemoryInt32
              else raise ArgumentError, "Unknown type '#{type}'."
              end

      variable = klass.new(name, address)

      if variable.is_a?(Storage::MemoryWord) && memory_type == :program_memory
        variable.size = @address_increment
      end

      vars_by_address = @vars_for_memory_by_address[memory_type]
      variable.addresses.each do |address|
        if vars_by_address[address]
          raise 'Variable %s overlaps with %s at 0x%x' %
            [variable, @vars_by_address[address], address]
        end
        vars_by_address[address] = variable
      end

      @vars_for_memory[memory_type][name] = variable
    end

    def vars_for_memory(memory_type)
      @vars_for_memory[memory_type]
    end

    def bind(memories)
      vars = {}
      memories.each do |memory_type, memory|
        @vars_for_memory[memory_type].each do |name, unbound_var|
          vars[name] = Variable.new(unbound_var.bind(memory))
        end
      end
      vars
    end
  end
end
