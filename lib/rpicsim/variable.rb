module RPicSim
  class Variable
    # Creates a new Variable object.
    # @param storage The internal storage for the variable.
    def initialize(storage)
      @storage = storage
    end

    # Reads the value of the variable.
    # @return [Integer]
    def value
      @storage.value
    end

    # Writes the value to the variable.
    # @return [Integer]
    def value=(val)
      @storage.value = val
    end

    # Writes the value to the variable in a lower-level way that
    # overrides any read-only bits.
    # For some types of variables, this is the same as {#value=}.
    def memory_value=(val)
      @storage.memory_value = val
    end

    # Reads the value directly from the memory object backing the register.
    # For some types of variables, this is the same as {#value}.
    def memory_value
      @storage.memory_value
    end

    def to_s
      @storage.to_s
    end

    def addresses
      @storage.addresses
    end

    def address
      @storage.address
    end

    def name
      @storage.name
    end
  end
end
