module RPicSim::Mplab
  class MplabMemory
    # @param memory Should implement the interface com.microchip.mplab.mdbcore.memory.Memory
    def initialize(memory)
      @memory = memory
    end
    
    def write_word(address, value)
      @memory.WriteWord(address, value)
      value
    end
    
    def read_word(address)
      @memory.ReadWord(address)
    end
    
    def is_valid_address?(address)
      @memory.IsValidAddress(address)
    end
  end
end