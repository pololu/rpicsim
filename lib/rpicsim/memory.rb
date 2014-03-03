class Memory
  # This object allows read and write access to the current data
  # stored in a memory space of the simulated device.
  #
  # The behavior of this class differs depending on what kind of Memory
  # it represents, as shown in the table below:
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

  def write_word(address, value)
    @mplab_memory.write_word(address, value)
  end
  
  def read_word(address)
    @mplab_memory.read_word(address)
  end
  
  def []=(address, value)
    write_word address, value
  end

  def [](address)
    read_word address
  end
  
  def is_valid_address?(address)
    @mplab_memory.is_valid_address?(address)
  end

end