require_relative 'mplab_observer'

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
    
    def on_change(&callback)
      MplabObserver.new(@memory) do |event|
        break if event.EventType != Mdbcore.memory::MemoryEvent::EVENTS::MEMORY_CHANGED
        address_ranges = event.AffectedAddresses.map do |mr|
          mr.Address...(mr.Address+mr.Size)
        end
        yield address_ranges
      end
    end
  end
end