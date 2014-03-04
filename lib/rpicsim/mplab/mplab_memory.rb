require_relative 'mplab_observer'

module RPicSim::Mplab
  class MplabMemory
    # @param memory Should implement the interface com.microchip.mplab.mdbcore.memory.Memory
    def initialize(memory)
      @memory = memory
    end
    
    def read_bytes(address, size)
      array = Java::byte[size].new
      @memory.Read(address, size, array)
      (0...size).collect &array.method(:ubyte_get)
    end
    
    def write_bytes(address, bytes)
      array = Java::byte[bytes.size].new
      bytes.each_with_index { |b, i| array.ubyte_set(i, b) }
      @memory.Write(address, array.size, array)
      bytes
    end
    
    def read_byte(address)
      array = [0].to_java(:byte)
      @memory.Read(address, 1, array)
      array.ubyte_get(0)
    end

    def write_byte(address, byte)
      write_bytes(address, [byte])
      byte
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
        next if event.EventType != Mdbcore.memory::MemoryEvent::EVENTS::MEMORY_CHANGED
        address_ranges = event.AffectedAddresses.map do |mr|
          mr.Address...(mr.Address+mr.Size)
        end
        yield address_ranges
      end
    end
  end
end