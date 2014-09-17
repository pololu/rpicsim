require 'set'

# @api public
module RPicSim
  # This class can attach to an MPLAB X memory class and watch for changes in it, and
  # report those changes as a hash associating variable names to new values.  This is
  # very useful for writing tests that assert that not only were the desired variables
  # written to, but also that no other variables were written to.
  #
  # This class does not analyze the current instruction being executed; it uses the
  # Attach method of the MPLAB X memory classes.  This means that it doesn't work properly
  # in some versions of MPLAB X.  See {file:docs/Flaws.textile}.
  #
  # @api public
  class MemoryWatcher
    # Allows you to read or write the list of variable names whose changes will
    # be ignored.  By default, this includes registers like WREG and STATUS that
    # change a lot.
    #
    # @return [Array(Symbol)]
    attr_accessor :var_names_ignored

    # Creates a new instance.
    # @param sim [Sim]
    # @param memory [Mplab::MplabMemory] The memory to watch
    # @param vars [Array(Variable)]
    def initialize(sim, memory, vars)
      # Populate the @vars_by_address instance hash
      @vars_by_address = {}
      vars.each do |var|
        var.addresses.each do |address|
          if @vars_by_address[address]
            raise 'Variable %s overlaps with %s at 0x%x' %
              [var, @vars_by_address[address], address]
          end
          @vars_by_address[address] = var
        end
      end

      @sim = sim
      @memory = memory
      @memory.on_change { |ar| handle_change(ar) }

      @vars_written = Set.new
      @var_names_ignored = default_var_names_ignored(sim.device)
    end

    # Generate a nice report of what variables have been written to since the
    # last time {#clear} was called.
    # @return [Hash] A hash where the keys are names (as symbols) of variables that were
    #   written to, and the value is the variable's current value.
    #   If an address was written to that does not correspond to a variable, the key for
    #   that will just be address as an integer.
    def writes
      hash = {}
      @vars_written.each do |var|
        if var.is_a? Integer
          hash[var] = @memory.read_word(var)
        else
          hash[var.name] = var.value
        end
      end
      hash
    end

    # Clears the record of what variables have been written to.
    def clear
      @vars_written.clear
    end

    private

    def handle_change(address_ranges)
      addresses = address_ranges.flat_map(&:to_a)
      vars = addresses.map { |a| @vars_by_address[a] || a }

      remove_vars(vars, @var_names_ignored)

      # The line below works because @vars_written is a Set, not a Hash.
      @vars_written.merge vars
    end

    def remove_vars(vars, var_names_to_remove)
      vars.reject! do |key, val|
        name = key.is_a?(Integer) ? key : key.name
        var_names_to_remove.include?(name)
      end
    end

    def default_var_names_ignored(device_name)
      # The datasheet says the PCLATH is not affected by pushing or popping the stack, but
      # we still get spurious events for it when a return instruction is executed.

      [:PCL, :PCLATH, :WREG, :STATUS, :BSR]
    end
  end
end
