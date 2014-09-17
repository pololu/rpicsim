# @api public
module RPicSim
  # Represents a stack trace from the simulated firmware.
  #
  # @api public
  class StackTrace
    # Array of {StackTraceEntry} objects.  The last one represents where the
    # program counter (PC) is.  The entries before the last one approximately
    # represent addresses of CALL or RCALL instructions that have not yet
    # returned.
    #
    # @return An array of {StackTraceEntry} objects.
    attr_reader :entries

    # @api private
    def initialize(entries = [])
      @entries = entries
    end

    # Prints the stack trace to the specified IO object, preceding
    # each line with the specified padding string.
    #
    # Example usage:
    #
    #     stack_trace.output($stdout, '  ')
    #
    # @param io An object that behaves like a writable IO object.
    # @param padding [String]
    def output(io, padding = '')
      @entries.reverse_each do |entry|
        output_entry(entry, io, padding)
      end
    end

    private

    def output_entry(entry, io, padding)
      io.puts padding + entry.description
    end
  end

  # Represents an entry in a {StackTrace}.
  #
  # @api public
  class StackTraceEntry
    # @return [Integer]
    attr_reader :address

    # @return [String]
    attr_reader :description

    # @api private
    def initialize(address, description)
      @address = address
      @description = description
    end

    # @return [String]
    def to_s
      description
    end
  end
end
