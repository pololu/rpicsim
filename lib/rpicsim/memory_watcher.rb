require 'set'

module RPicSim
  # This class can attach to an MPLAB X memory class and watch for changes in it, and
  # report those changes as a hash associating variable names to new values.  This is
  # very useful for writing tests that assert that not only were the desired variables
  # written to, but also that no other variables were written to.
  #
  # This class does not analyze the current instruction being executed; it uses the
  # Attach method of the MPLAB X memory classes.  This means that it doesn't work properly
  # in some versions of MPLAB X.  See {file:docs/Flaws.textile}.
  class MemoryWatcher
    include Java::comMicrochipMplabUtilObservers::Observer
    
    attr_accessor :var_names_ignored
    attr_accessor :var_names_ignored_on_first_step
    
    # Creates a new instance.
    # @param sim [Sim]
    # @param memory [Mplab::MplabMemory] The memory to watch
    # @param vars [Array(Variable)]
    def initialize(sim, memory, vars)
      memory = memory.instance_variable_get(:@memory)  # TODO: remove
    
      # Populate the @vars_by_address instance hash
      @vars_by_address = {}
      vars.each do |var|
        var.addresses.each do |address|
          if @vars_by_address[address]
            raise "Variable %s overlaps with %s at 0x%x" %
              [var, @vars_by_address[address], address]
          end
          @vars_by_address[address] = var
        end
      end
    
      @sim = sim
      @memory = memory
      @memory.Attach(self, nil)      
      @vars_written = Set.new
      @var_names_ignored = default_var_names_ignored(sim.device)
      @var_names_ignored_on_first_step = default_var_names_ignored_on_first_step(sim.device)
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
          hash[var] = @memory.ReadWord(var)
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
    
    def default_var_names_ignored(device_name)
      # The datasheet says the PCLATH is not affected by pushing or popping the stack, but
      # we still get spurious events for it when a return instruction is executed.

      [:PCL, :PCLATH, :STATUS]
    end
    
    def default_var_names_ignored_on_first_step(device_name)
      #TODO: get rid of this stuff? people should just have a goto or something harmless at
      # the beginning of their program and take a single step like we do.
      [:PORTA, :LATA, :OSCCON, :PMCON2, :INTCON]
    end
    
    # This gets called by MPLAB X code to report events on the memory.
    def Update(event)
      return if event.EventType != Mdbcore.memory::MemoryEvent::EVENTS::MEMORY_CHANGED
      
      addresses = event.AffectedAddresses.flat_map do |mr|
        (mr.Address...(mr.Address+mr.Size)).to_a
      end
      vars = addresses.map { |a| @vars_by_address[a] || a }

      remove_vars(vars, @var_names_ignored)
      remove_vars(vars, @var_names_ignored_on_first_step) if @sim.cycle_count <= 1
      
      # The line below works because @vars_written is a Set, not a Hash.
      @vars_written.merge vars
    end

    private
    def remove_vars(vars, var_names_to_remove)
      vars.reject! do |key, val|
        name = key.is_a?(Integer) ? key : key.name
        var_names_to_remove.include?(name)
      end
    end
   
  end
end