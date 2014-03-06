module RPicSim
  # This class wraps two or more memory objects and
  # provides an interface that is also like {RPicSim::Memory}.
  # Any reads or writes from the composite memory will go to the first
  # component memory for which the address is valid.
  class CompositeMemory
    # Creates a new instance.
    # The memory objects given must support the following methods:
    #
    # * +read_byte+
    # * +write_byte+
    # * +read_word+
    # * +write_word+
    # * +valid_address?+
    #
    # @param memories [Array]
    def initialize(memories)
      @memories = memories
    end

    def read_byte(address)
      memory(address).read_byte(address)
    end

    def write_byte(address, value)
      memory(address).write_byte(address, value)
    end

    def read_word(address)
      memory(address).read_word(address)
    end

    def write_word(address, value)
      memory(address).write_word(address, value)
    end

    def valid_address?(address)
      find_memory(address) != nil
    end

    private

    def find_memory(address)
      @memories.find do |memory|
        memory.valid_address?(address)
      end
    end

    def memory(address)
      find_memory(address) or raise 'Invalid memory address %#x.' % address
    end
  end
end
