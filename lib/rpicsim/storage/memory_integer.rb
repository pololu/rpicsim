module RPicSim::Storage
  # This class and its subclasses represent integers stored in RAM.
  class MemoryInteger
    attr_reader :name, :address
    attr_writer :memory

    # Creates a new MemoryInteger object not bound to any memory yet.
    # @param name [Symbol] The name of the variable.
    # @param address [Integer] should be the address of the variable
    def initialize(name, address)
      @name = name
      @address = address
    end

    # Creates a new Variable that is bound to the specified memory.
    # @param memory [RPicSim::Memory]
    def bind(memory)
      bound_var = dup
      bound_var.memory = memory
      bound_var
    end

    # @return [Range] The addresses of each byte that is part of this variable.
    def addresses
      address ... (address + size)
    end

    # Reads the value of the variable from memory.
    # @return [Integer]
    def value
      raise NoMethodError, 'value not implemented'
    end

    # Writes to the value to the variable's memory.
    # @return [Integer]
    def value=(val)
      raise NoMethodError, 'value= not implemented'
    end

    def memory_value=(val)
      self.value = val
    end

    def memory_value(val)
      self.value
    end

    def to_s
      name.to_s
    end

    def inspect
      '<%s %s 0x%x>' % [self.class, name, address]
    end

    private
    def check_value(value, allowed_values)
      if !allowed_values.include?(value)
        raise ArgumentError, "Invalid value #{value} written to #{name}."
      end
    end
  end

  # Represents an unsigned 8-bit variable.
  class MemoryUInt8 < MemoryInteger
    def size
      1
    end

    def value
      @memory.read_byte(@address)
    end

    def value=(val)
      check_value val, 0..255
      @memory.write_byte(@address, val)
    end

  end

  # Represents a signed 8-bit variable.
  class MemoryInt8 < MemoryInteger
    def size
      1
    end

    def value
      val = @memory.read_byte(@address)
      val -= 0x100 if val >= 0x80
      val
    end

    def value=(val)
      check_value val, -0x80...0x80
      @memory.write_byte(@address, val & 0xFF)
      @memory.write_byte(@address + 1, (val >> 8) & 0xFF)
    end
  end

  # Represents an unsigned 16-bit variable.
  class MemoryUInt16 < MemoryInteger
    def size
      2
    end

    def value
      @memory.read_byte(@address) + 256 * @memory.read_byte(@address + 1)
    end

    def value=(val)
      check_value val, 0...0x10000
      @memory.write_byte(@address, val & 0xFF)
      @memory.write_byte(@address + 1, (val >> 8) & 0xFF)
    end
  end

  # Represents a signed 16-bit variable.
  class MemoryInt16 < MemoryInteger
    def size
      2
    end

    def value
      val = @memory.read_byte(@address) + 256 * @memory.read_byte(@address + 1)
      val -= 0x10000 if val >= 0x8000
      val
    end

    def value=(val)
      check_value val, -0x8000...0x8000
      @memory.write_byte(@address, val & 0xFF)
      @memory.write_byte(@address + 1, (val >> 8) & 0xFF)
    end
  end

  # Represents an unsigned 24-bit variable.
  class MemoryUInt24 < MemoryInteger
    def size
      3
    end

    def value
      @memory.read_byte(@address) + 0x100 * @memory.read_byte(@address + 1) +
        0x10000 * @memory.read_byte(@address + 2)
    end

    def value=(val)
      check_value val, 0...0x1000000
      @memory.write_byte(@address, val & 0xFF)
      @memory.write_byte(@address + 1, (val >> 8) & 0xFF)
      @memory.write_byte(@address + 2, (val >> 16) & 0xFF)
    end
  end

  # Represents a signed 24-bit variable.
  class MemoryInt24 < MemoryInteger
    def size
      3
    end

    def value
      val = @memory.read_byte(@address) + 0x100 * @memory.read_byte(@address + 1) +
        0x10000 * @memory.read_byte(@address + 2)
      val -= 0x1000000 if val >= 0x800000
      val
    end

    def value=(val)
      check_value val, -0x800000..0x800000
      @memory.write_byte(@address, val & 0xFF)
      @memory.write_byte(@address + 1, (val >> 8) & 0xFF)
      @memory.write_byte(@address + 2, (val >> 16) & 0xFF)
    end
  end

  # Represents an unsigned 32-bit variable.
  class MemoryUInt32 < MemoryInteger
    def size
      4
    end

    def value
      @memory.read_byte(@address) + 0x100 * @memory.read_byte(@address + 1) +
        0x10000 * @memory.read_byte(@address + 2) +
        0x1000000 * @memory.read_byte(@address + 3)
    end

    def value=(val)
      check_value val, 0...0x100000000
      @memory.write_byte(@address, val & 0xFF)
      @memory.write_byte(@address + 1, (val >> 8) & 0xFF)
      @memory.write_byte(@address + 2, (val >> 16) & 0xFF)
      @memory.write_byte(@address + 3, (val >> 24) & 0xFF)
    end
  end

  # Represents a signed 32-bit variable.
  class MemoryInt32 < MemoryInteger
    def size
      4
    end

    def value
      val = @memory.read_byte(@address) + 0x100 * @memory.read_byte(@address + 1) +
        0x10000 * @memory.read_byte(@address + 2) +
        0x1000000 * @memory.read_byte(@address + 3) +
        0x100000000 * @memory.read_byte(@address + 4)
      val -= 0x100000000 if val >= 0x80000000
      val
    end

    def value=(val)
      check_value val, -0x80000000..0x80000000
      @memory.write_byte(@address, val & 0xFF)
      @memory.write_byte(@address + 1, (val >> 8) & 0xFF)
      @memory.write_byte(@address + 2, (val >> 16) & 0xFF)
      @memory.write_byte(@address + 3, (val >> 24) & 0xFF)
    end
  end

  # Represents a word-sized variable.
  # The size of the word will depend on the memory the variable lives in.
  class MemoryWord < MemoryInteger
    attr_accessor :size

    def value
      @memory.read_word(@address)
    end

    def value=(val)
      @memory.write_word(@address, val)
    end
  end

end
