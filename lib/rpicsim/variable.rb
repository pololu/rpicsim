module RPicSim
  # This class and its subclasses represent firmware-defined variables
  # in RAM or flash.
  #
  # Instances of this class come in two varieties:
  # - Unbound variables are just a name and an address.
  # - Bound variables have a name and an address and they are attached to
  #   a memory object so you can actually read and write values from them.
  class Variable
    module ClassMethods
      # @return (Integer) The size of this type of variable in memory words.
      attr_reader :size

      # Specifies the size of this class of variables in memory words.
      # The units for this are usually bytes for RAM and more than a byte
      # for flash.  This should be called inside the definition of a subclass of
      # {Variable}, not from anywhere else.
      def size_is(size)
        @size = size
      end
    end

    extend ClassMethods

    attr_reader :name, :address
    attr_writer :memory

    # Creates a new Variable object not bound to any memory yet.
    # @param name [Symbol] The name of the variable.
    # @param address [Integer] should be the address of the variable
    def initialize(name, address)
      @name = name
      @address = address
    end

    # Creates a new Variable that is bound to the specified memory.
    # @param memory [MPlab::MPlabMemory]
    def bind(memory)
      bound_var = dup
      bound_var.memory = memory
      bound_var
    end

    # @return [Range] The addresses of each byte that is part of this variable.
    def addresses
      address ... (address + self.class.size)
    end

    # Reads the value of the variable from memory.
    # @return [Integer]
    def value
      raise NoMethodError, "value not implemented"
    end

    # Writes to the value to the variable's memory.
    # @return [Integer]
    def value=(val)
      raise NoMethodError, "value= not implemented"
    end

    def to_s
      name.to_s
    end

    def inspect
      "<%s %s 0x%x>" % [self.class, name, address]
    end
    
    private
    def check_value(value, allowed_values)
      if !allowed_values.include?(value)
        raise ArgumentError, "Invalid value #{value} written to #{name}."
      end
    end
  end

  # Represents an unsigned 8-bit variable.
  class VariableU8 < Variable
    size_is 1

    def value
      @memory.read_word(@address)
    end

    def value=(val)
      check_value val, 0..255
      @memory.write_word(@address, val)
    end

  end

  # Represents a signed 8-bit variable.
  class VariableS8 < Variable
    size_is 1

    def value
      val = @memory.read_word(@address)
      val -= 0x100 if val >= 0x80
      val
    end

    def value=(val)
      check_value val, -0x80...0x80
      @memory.write_word(@address, val & 0xFF)
      @memory.write_word(@address + 1, (val >> 8) & 0xFF)
    end
  end

  # Represents an unsigned 16-bit variable.
  class VariableU16 < Variable
    size_is 2

    def value
      @memory.read_word(@address) + 256 * @memory.read_word(@address + 1)
    end

    def value=(val)
      check_value val, 0...0x10000
      @memory.write_word(@address, val & 0xFF)
      @memory.write_word(@address + 1, (val >> 8) & 0xFF)
    end
  end

  # Represents a signed 16-bit variable.
  class VariableS16 < Variable
    size_is 2

    def value
      val = @memory.read_word(@address) + 256 * @memory.read_word(@address + 1)
      val -= 0x10000 if val >= 0x8000
      val
    end

    def value=(val)
      check_value val, -0x8000...0x8000
      @memory.write_word(@address, val & 0xFF)
      @memory.write_word(@address + 1, (val >> 8) & 0xFF)
    end
  end

  # Represents an unsigned 24-bit variable.
  class VariableU24 < Variable
    size_is 3

    def value
      @memory.read_word(@address) + 0x100 * @memory.read_word(@address + 1) +
        0x10000 * @memory.read_word(@address + 2)
    end

    def value=(val)
      check_value val, 0...0x1000000
      @memory.write_word(@address, val & 0xFF)
      @memory.write_word(@address + 1, (val >> 8) & 0xFF)
      @memory.write_word(@address + 2, (val >> 16) & 0xFF)
    end
  end

  # Represents a signed 24-bit variable.
  class VariableS24 < Variable
    size_is 3

    def value
      val = @memory.read_word(@address) + 0x100 * @memory.read_word(@address + 1) +
        0x10000 * @memory.read_word(@address + 2)
      val -= 0x1000000 if val >= 0x800000
      val
    end

    def value=(val)
      check_value val, -0x800000..0x800000
      @memory.write_word(@address, val & 0xFF)
      @memory.write_word(@address + 1, (val >> 8) & 0xFF)
      @memory.write_word(@address + 2, (val >> 16) & 0xFF)
    end
  end

  # Represents an unsigned 32-bit variable.
  class VariableU32 < Variable
    size_is 4

    def value
      @memory.read_word(@address) + 0x100 * @memory.read_word(@address + 1) +
        0x10000 * @memory.read_word(@address + 2) +
        0x1000000 * @memory.read_word(@address + 3)
    end

    def value=(val)
      check_value val, 0...0x100000000
      @memory.write_word(@address, val & 0xFF)
      @memory.write_word(@address + 1, (val >> 8) & 0xFF)
      @memory.write_word(@address + 2, (val >> 16) & 0xFF)
      @memory.write_word(@address + 3, (val >> 24) & 0xFF)
    end
  end

  # Represents a signed 32-bit variable.
  class VariableS32 < Variable
    size_is 4

    def value
      val = @memory.read_word(@address) + 0x100 * @memory.read_word(@address + 1) +
        0x10000 * @memory.read_word(@address + 2) +
        0x1000000 * @memory.read_word(@address + 3) +
        0x100000000 * @memory.read_word(@address + 4)
      val -= 0x100000000 if val >= 0x80000000
      val
    end

    def value=(val)
      check_value val, -0x80000000..0x80000000
      @memory.write_word(@address, val & 0xFF)
      @memory.write_word(@address + 1, (val >> 8) & 0xFF)
      @memory.write_word(@address + 2, (val >> 16) & 0xFF)
      @memory.write_word(@address + 3, (val >> 24) & 0xFF)
    end
  end

  # Represents a word-sized variable.
  # The size of the word will depend on the memory the variable lives in.
  class VariableWord < Variable
    size_is 1

    attr_writer :max_value

    def value
      @memory.read_word(@address)
    end

    def value=(val)
      if @max_value
        check_value val, 0..@max_value
      end
      @memory.write_word(@address, val)
    end
  end
end
