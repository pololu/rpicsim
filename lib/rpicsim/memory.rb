class Memory
  # This object allows read and write access to the current data
  # stored in a memory space of the simulated device.
  #
  # The behavior of +read_word+ and +write_word+ differs depending on
  # what kind of Memory it represents, as shown in the table below:
  #
  #                        Address type   Read/write chunk
  #     Any type of RAM:   Byte address   1 byte (8 bits)
  #     PIC18 code space:  Byte address   1 word (16 bits)
  #     Other code space:  Word address   1 word (12 or 14 bits)
  #
  # @param mplab_memory [Mplab::Memory]
  def initialize(mplab_memory)
    @mplab_memory = mplab_memory
  end
  
  def read_bytes(address, size)
    @mplab_memory.read_bytes(address, size)
  end
  
  def write_bytes(address, bytes)
    @mplab_memory.write_bytes(address, bytes)
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
  
  def is_valid_address?(address)
    @mplab_memory.is_valid_address?(address)
  end

end