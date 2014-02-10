class Memory
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
  
  def is_valid_address?(address)
    @mplab_memory.is_valid_address?(address)
  end
end