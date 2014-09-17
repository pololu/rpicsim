module RPicSim
  # This object allows read and write access to the data currently
  # stored in a memory space of the simulated device.
  # Instances are usually retrieved from a {Sim} object by calling
  # {Sim#ram}, {Sim#program_memory}, or {Sim#eeprom}.
  #
  # The behavior of +read_word+ and +write_word+ differs depending on
  # what kind of Memory is being used, as shown in the table below:
  #
  #     Memory type                Address type   Read/write chunk for word methods
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
  #
  # @api public
  class Memory
    # @param mplab_memory [Mplab::Memory]
    # @api private
    def initialize(mplab_memory)
      @mplab_memory = mplab_memory
    end

    # Reads the byte in memory at the specified address.
    #
    # @param address [Integer]
    # @return [Integer]
    def read_byte(address)
      @mplab_memory.read_byte(address)
    end

    # Writes the given integer to the byte in memory at the specified address.
    #
    # @param address [Integer]
    # @param value [Integer]
    def write_byte(address, value)
      @mplab_memory.write_byte(address, value)
    end

    # Reads the word in memory at the specified address.
    # @param address [Integer]
    # @return [Integer]
    def read_word(address)
      @mplab_memory.read_word(address)
    end

    # Writes the given integer to the word in memory at the specified address.
    # @param address [Integer]
    # @param value [Integer]
    def write_word(address, value)
      @mplab_memory.write_word(address, value)
    end

    # Returns true if the specified address is valid.
    # @param address [Integer]
    # @return true or false
    def valid_address?(address)
      @mplab_memory.valid_address?(address)
    end

    # Reads a series of bytes from the simulated memory using +read_byte+ and
    # returns them as an array.
    #
    # @param address [Integer] The address of the first byte to read.
    # @param size [Integer] The number of bytes to read.
    # @return [Array(Integer)]
    def read_bytes(address, size)
      size.times.map { |i| read_byte(address + i) }
    end

    # Writes a series of bytes to the simulated memory.
    #
    # @param address [Integer]
    # @param bytes Array of integers or a string.
    def write_bytes(address, bytes)
      bytes = bytes.bytes if bytes.is_a?(String)
      bytes.each_with_index { |b, i| write_byte(address + i, b) }
      nil
    end
  end
end
