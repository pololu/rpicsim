module RPicSim
  class StackTrace
    attr_reader :entries

    def initialize(entries = [])
      @entries = entries
    end

    def output(io, padding = '')
      @entries.reverse_each do |entry|
        output_entry(entry, io, padding)
      end
    end

    def output_entry(entry, io, padding)
      io.puts padding + entry.description
    end
  end

  class StackTraceEntry
    attr_reader :address, :description

    def initialize(address, description)
      @address = address
      @description = description
    end

    def to_s
      description
    end
  end
end
