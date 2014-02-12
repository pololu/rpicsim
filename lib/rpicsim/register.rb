module RPicSim
  class Register
    attr_reader :name
    
    # The size of the register in bytes.
    attr_reader :size
  
    # @param register [Mplab::MplabRegister]
    # @param memory An optional parameter that enables memory_value.
    def initialize(mplab_register, memory, width)
      @mplab_register = mplab_register
      @name = mplab_register.name.to_sym
      
      @size = case width
              when 8 then 1
              when 16 then 2
              when 24 then 3
              when 32 then 4
              else raise "Unsupported register width: #{name} is #{width}-bit."
              end
      
      var_type = case size
                 when 1 then VariableU8
                 when 2 then VariableU16
                 when 3 then VariableU24
                 when 4 then VariableU32
                 end
      
      @var = var_type.new(name, address).bind(memory)
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
      @var.value = value
    end
    
    # Reads the value directly from the memory object backing the register.
    def memory_value
      @var.value
    end

    # Gets the address of the register.
    # @return [Integer]
    def address
      @mplab_register.address
    end
    
    # Gets the range of addresses occupied.
    # @return [Range] A range of integers.
    def addresses
      address...(address + size)
    end
    
    def to_s
      name.to_s
    end
    
    def inspect
      "<%s %s 0x%x>" % [self.class, name, address]
    end
  end
end