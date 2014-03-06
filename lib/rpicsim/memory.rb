module RPicSim
  # This object allows read and write access to the data currently
  # stored in a memory space of the simulated device.
  # Instances are usually retrieved from a {Sim} object by calling
  # {Sim#ram}, {Sim#program_memory}, or {Sim#eeprom}.
  #
  # The behavior of +read_word+ and +write_word+ differs depending on
  # what kind of Memory is being used, as shown in the table below:
  #
  #     Memory type                Address type   Read/write chunk
  #     RAM and EEPROM:            Byte address   1 byte (8 bits)
  #     PIC18 program memory:      Byte address   1 word (16 bits)
  #     Non-PIC18 program memory:  Word address   1 word (12 or 14 bits)
  #
  # The +read_byte+ and +write_byte+ methods use the same type of address as
  # +read_word+ and +write_word+, but they can only read and write from the
  # lower 8 bits of the word.
  # The upper bits of the word, if there are any, are left unchanged.
  # For RAM and EEPROM, +read_byte+ and +write_byte+ behave the same way as
  # +read_word+ and +write_word+.
  #
  # For more information, see {file:Memories.md}.
  class Memory
    # @param mplab_memory [Mplab::Memory]
    def initialize(mplab_memory)
      @mplab_memory = mplab_memory
    end
    
    def read_byte(address)
      @mplab_memory.read_byte(address)
    end
    
    def write_byte(address, value)
      @mplab_memory.write_byte(address, value)
    end
    
    def read_word(address)
      @mplab_memory.read_word(address)
    end
    
    def write_word(address, value)
      @mplab_memory.write_word(address, value)
    end
    
    def valid_address?(address)
      @mplab_memory.valid_address?(address)
    end

  end
end