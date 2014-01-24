module RPicSim
  class Register
    attr_reader :name
  
    # @param register An object that implements com.microchip.mplab.mdbcore.simulator.Register
    # @param memory An optional parameter that enables memory_value.
    def initialize(register, memory = nil)
      @register = register
      @name = register.getName.to_sym
      @memory = memory
    end

    # Sets the value of the register.
    # @param val [Integer]
    def value=(val)
      @register.write val
    end
    
    # Reads the value of the register.
    # @return [Integer]
    def value
      @register.read
    end
    
    # For some registers, like STATUS, you cannot read and write the full
    # range of possible values using {#value=} because some bits are not
    # writable by the CPU.
    # This setter gets around that by writing directly to the memory object
    # that backs the register.
    def memory_value=(value)
      @memory.WriteWord(address, value)
    end
    
    # Reads the value directly from the memory object backing the register.
    def memory_value
      @memory.ReadWord(address)    
    end

    # Gets the address of the register.
    # @return [Integer]
    def address
      @register.getAddress
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