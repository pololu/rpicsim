module RPicSim
  class Register
    attr_reader :name
  
    # @param register [Mplab::MplabRegister]
    # @param memory An optional parameter that enables memory_value.
    def initialize(mplab_register, memory = nil)
      @mplab_register = mplab_register
      @name = mplab_register.name.to_sym
      @memory = memory
    end

    # Sets the value of the register.
    # @param val [Integer]
    def value=(val)
      @mplab_register.write val
    end
    
    # Reads the value of the register.
    # @return [Integer]
    def value
      @mplab_register.read
    end
    
    # For some registers, like STATUS, you cannot read and write the full
    # range of possible values using {#value=} because some bits are not
    # writable by the CPU.
    # This setter gets around that by writing directly to the memory object
    # that backs the register.
    def memory_value=(value)
      @memory.write_word(address, value)
    end
    
    # Reads the value directly from the memory object backing the register.
    def memory_value
      @memory.read_word(address)    
    end

    # Gets the address of the register.
    # @return [Integer]
    def address
      @mplab_register.address
    end
    
    # Gets the range of addresses occupied.
    # @return [Range] A range of integers.
    def addresses
      address..address
    end
    
    def to_s
      name.to_s
    end
    
    def inspect
      "<%s %s 0x%x>" % [self.class, name, address]
    end
  end
end