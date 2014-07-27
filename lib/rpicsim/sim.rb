require 'forwardable'

require_relative 'mplab'
require_relative 'flaws'
require_relative 'pin'
require_relative 'memory'
require_relative 'composite_memory'
require_relative 'storage/register'
require_relative 'symbol_set'
require_relative 'variable_set'
require_relative 'program_counter'
require_relative 'label'
require_relative 'memory_watcher'
require_relative 'program_file'
require_relative 'stack_pointer'
require_relative 'stack_trace'

module RPicSim
  # This class represents a PIC microcontroller simulation.
  # This class keeps track of the state of the simulation and provides methods for
  # running the simulation, reading the state, and changing the state.
  class Sim
    # These methods should be called while defining a subclass of {Sim}.
    module ClassDefinitionMethods
      # Specifies what exact device the firmware runs on.
      # @param device [String] The device name, for example "PIC10F322".
      def use_device(device)
        @device = device
        @assembly = Mplab::MplabAssembly.new(device)
      end

      # Specifies the path to the firmware file.  The file can be a HEX or COF file, but
      # COF is recommended so that you can access symbol/label addresses and other
      # debugging information.
      # You must call {#use_device} before calling this.
      def use_file(filename)
        raise "The device needs to be specified before filename (e.g. 'use_device \"PIC10F322\"')" unless @device
        @filename = filename.to_s
        load_program_file
      end

      # Specifies additional symbols to use in the simulation.  Symbols might be
      # loaded from the program file when you call {#use_file}, but if those
      # symbols are not sufficient then you can call this method to incorporate
      # another source of symbols.
      #
      # The +symbol_source+ parameter should be an object that responds to some
      # subset of these methods: +#symbols+, +#symbols_in_ram+,
      # +#symbols_in_program_memory+, +#symbols_in_eeprom+.  The methods should
      # take no arguments and return a hash where the keys are symbol names
      # (represented as Ruby symbols) and the values are addresses (as
      # integers).
      def use_symbols(symbol_source)
        if symbol_source.respond_to?(:symbols)
          @symbol_set.def_symbols symbol_source.symbols
        end

        if symbol_source.respond_to?(:symbols_in_ram)
          @symbol_set.def_symbols symbol_source.symbols_in_ram, :ram
        end

        if symbol_source.respond_to?(:symbols_in_program_memory)
          @symbol_set.def_symbols symbol_source.symbols_in_program_memory, :program_memory
        end

        if symbol_source.respond_to?(:symbols_in_eeprom)
          @symbol_set.def_symbols symbol_source.symbols_in_eeprom, :eeprom
        end
      end

      # Define a symbol.
      # Normally symbols are loaded by {#use_file} or {#use_symbols}, but you can
      # this method allows for adding additional symbols one at a time.
      #
      # @param name [Symbol] The name of the symbol.
      # @param address [Integer] The address of the symbol.
      # @param memory_type [Symbol] (optional) The type of memory the symbol
      #   belongs to.  This should either by +:ram+, +:program_memory+, or
      #   +:eeprom+.
      def def_symbol(name, address, memory_type = nil)
        @symbol_set.def_symbol name, address, memory_type
      end

      # Define a pin alias.
      #
      # @param our_name [Symbol] Specifies what you would like to
      #   call the pin.
      #   A method with this name will be added to your class's +Shortcuts+ module so it
      #   is available as a method on instances of your class and also in your RSpec tests.
      # @param datasheet_name [Symbol] A symbol like :RB3 that specifies what pin it is.
      def def_pin(our_name, datasheet_name)
        our_name = our_name.to_sym
        @pin_aliases[our_name] = datasheet_name.to_sym

        self::Shortcuts.send(:define_method, our_name) { pin our_name }
      end

      # Define a variable.
      # @param name [Symbol] Specifies what you would like to call the variable.
      #   A method with this name will be added to your class's +Shortcuts+ module so it
      #   is available as a method on instances of your class and also in your RSpec tests.
      #   The method will return a {Variable} object that you can use to read or write the
      #   value of the actual variable in the simulation.
      # @param type [Symbol] Specifies how to interpret the data in the variable and its size.
      #   For integers, it should be one of +:uint8+, +:int8+, +:uint16+, +:int16+, +:uint24+, +:int24+, +:uint32+, +:int32+, or +:word+.
      #   The +s+ stands for signed and the +u+ stands for unsigned, and the number stands for the number
      #   of bits.  All multi-byte integers are considered to be little Endian.
      # @param opts [Hash] Specifies additional options.  The options are:
      #   * +:memory+: Specifies the memory that the variable lives in.
      #     Valid values are +:ram+ (default), +:eeprom+, and +:program_memory+.
      #   * +:symbol+: By default, we look for a symbol with the same name as the variable and
      #     use that as the location of the variable.  This option lets you specify a different
      #     symbol to look for in the firmware, so you could call the variable one thing in your
      #     firmware and call it a different thing in your tests.
      #     This option is ignored if +:address is specified.
      #   * +:address+: An integer to use as the address of the variable.
      def def_var(name, type, opts = {})
        if @variable_set.nil?
          raise 'The device and filename need to be specified before defining variables.'
        end

        @variable_set.def_var(name, type, opts)

        self::Shortcuts.send(:define_method, name) { var name }
      end
    end

    # These are class methods that you can call on subclasses of {Sim}.
    module ClassMethods
      # A string like "PIC10F322" specifying the PIC device number.
      attr_reader :device

      # The path to a COF file for the PIC firmware, which was originally passed
      # to the constructor.
      attr_reader :filename

      # A hash that associates our names for pins (like :main_output_pin) to datasheet
      # pin names (like :RB3).  These aliases are defined by {ClassDefinitionMethods#def_pin}.
      attr_reader :pin_aliases

      # A {VariableSet} that holds information about all the variables that were defined
      # with {ClassDefinitionMethods#def_var def_var}.
      attr_reader :variable_set

      # The {ProgramFile} object representing the firmware.
      attr_reader :program_file

      # Returns all the symbols known to the simulation.
      # The returns value is a hash where the keys are the names of the symbols
      # (represented as Ruby symbols) and the values are the addresses of the symbols.
      def symbols
        @symbol_set.symbols
      end

      # Returns all the symbols in RAM.
      # The returns value is a hash where the keys are the names of the symbols
      # (represented as Ruby symbols) and the values are the addresses of the symbols.
      def symbols_in_ram
        @symbol_set.symbols_in_memory(:ram)
      end

      # Returns all the symbols in program memory.
      # The returns value is a hash where the keys are the names of the symbols
      # (represented as Ruby symbols) and the values are the addresses of the symbols.
      def symbols_in_program_memory
        @symbol_set.symbols_in_memory(:program_memory)
      end

      # Returns all the symbols in EEPROM.
      # The returns value is a hash where the keys are the names of the symbols
      # (represented as Ruby symbols) and the values are the addresses of the symbols.
      def symbols_in_eeprom
        @symbol_set.symbols_in_memory(:eeprom)
      end

      # Returns a hash that associates label names as Ruby symbols to {Label} objects.
      def labels
        program_file.labels
      end

      # Returns a {Label} object if a program label by that name is found.
      # The name is specified in the code that defined the label.  If you are using a C compiler,
      # you will probably need to prefix the name with an underscore.
      # @return [Label]
      def label(name)
        program_file.label(name)
      end

      private

      # This gets called when a new subclass of PicSim is created.
      def inherited(subclass)
        subclass.instance_eval do
          @pin_aliases = {}
          const_set :Shortcuts, Module.new
          include self::Shortcuts
        end
      end

      def load_program_file
        @program_file = ProgramFile.new(@filename, @device)

        @symbol_set = SymbolSet.new
        @symbol_set.def_memory_type :ram
        @symbol_set.def_memory_type :program_memory
        @symbol_set.def_memory_type :eeprom

        use_symbols(@program_file)

        @variable_set = VariableSet.new
        @variable_set.address_increment = program_file.address_increment
        @variable_set.def_memory_type :ram, @symbol_set.symbols_in_memory(:ram)
        @variable_set.def_memory_type :program_memory,
          @symbol_set.symbols_in_memory(:program_memory)
        @variable_set.def_memory_type :eeprom, @symbol_set.symbols_in_memory(:eeprom)
      end
    end

    # This module is used in RPicSim's {file:RSpecIntegration.md RSpec integration}
    # in order to let you call basic methods on the {RPicSim::Sim} object without having
    # to prefix them with anything.
    module BasicShortcuts
      # This is the complete list of the basic shortcuts.
      # You can call any of these methods by simply writing its name along with any arguments
      # in an RSpec example.
      #
      # For example, these shortcuts allow you to just write +cycle_count+
      # instead of +sim.cycle_count+.
      ForwardedMethods = [
        :cycle_count,
        :eeprom,
        :every_step,
        :goto,
        :label,
        :labels,
        :location_address,
        :new_ram_watcher,
        :pc,
        :pc_description,
        :pin,
        :program_file,
        :program_memory,
        :ram,
        :run_cycles,
        :run_steps,
        :run_subroutine,
        :run_to,
        :run_to_cycle_count,
        :reg,
        :stack_contents,
        :stack_memory,
        :stack_push,
        :stack_trace,
        :step,
        :var,
        :wreg,
        :stack_pointer,
        :stkptr,
        # TODO: shortcuts for symbols and symbols_in_* methods
      ]

      extend Forwardable
      def_delegators :@sim, *ForwardedMethods
    end

    extend ClassDefinitionMethods, ClassMethods

    # Gets the program counter, an object that lets you read and write the
    # current address in program space that is being executed.
    # @return [RPicSim::ProgramCounter]
    attr_reader :pc

    # Returns a {Variable} object corresponding to WREG.  You can use this
    # to read and write the value of the W register.
    # @return [Register]
    attr_reader :wreg

    # Returns a {Variable} object corresponding to the stack pointer register.
    # You can use this to read and write the value of the stack pointer.
    # @return [Register]
    attr_reader :stkptr

    # Returns a {StackPointer} object that is like {#stkptr} but it works
    # consistently across all PIC devices.  The initial value is always 0
    # when the stack is empty and it points to the first unused space in
    # the stack.
    # @return [StackPointer]
    attr_reader :stack_pointer

    # Returns a {Memory} object that allows direct reading and writing of the
    # bytes in the simulated RAM.
    # @return [Memory]
    attr_reader :ram

    # Returns a {Memory} object that allows direct reading and writing of the
    # data in the program memory.
    # Besides the main program, the program memory also contains the
    # configuration words and the user IDs.
    # @return [Memory]
    attr_reader :program_memory

    # Returns a {Memory} object that allows direct reading and writing of the
    # bytes in the simulated EEPROM.
    # @return [Memory]
    attr_reader :eeprom

    # Returns a {Memory} object that allows direct reading and writing of the
    # bytes in the simulated hardware call stack.
    # @return [Memory]
    attr_reader :stack_memory

    # Returns a string like "PIC10F322" specifying the PIC device number.
    # @return [String]
    def device
      self.class.device
    end

    # Returns the path to the firmware file.
    # @return [String]
    def filename
      self.class.filename
    end

    # Makes a new simulation using the settings specified when the class was defined.
    def initialize
      @assembly = Mplab::MplabAssembly.new(device)
      @assembly.start_simulator_and_debugger(filename)
      @simulator = @assembly.simulator
      @processor = @simulator.processor

      initialize_memories
      initialize_pins
      initialize_sfrs_and_nmmrs
      initialize_vars

      @pc = ProgramCounter.new @simulator.processor

      @step_callbacks = []

      @stack_pointer = StackPointer.new(stkptr)
    end

    private

    def initialize_memories
      # Set up our stores and helper objects.
      @ram = Memory.new @simulator.fr_memory
      @eeprom = Memory.new @simulator.eeprom_memory
      @sfr_memory = Memory.new @simulator.sfr_memory
      @nmmr_memory = Memory.new @simulator.nmmr_memory
      @stack_memory = Memory.new @simulator.stack_memory

      # config_memory must be before test_memory, because test_memory provides
      # bad values for the configuration words.
      @program_memory = Memory.new CompositeMemory.new [
        @simulator.program_memory,
        @simulator.config_memory,
        @simulator.test_memory,
      ]
    end

    def initialize_pins
      pins = @simulator.pins.map { |mplab_pin| Pin.new(mplab_pin) }

      @pins_by_name = {}
      pins.each do |pin|
        pin.names.each do |name|
          @pins_by_name[name.to_sym] = pin
        end
      end

      self.class.pin_aliases.each do |our_name, datasheet_name|
        @pins_by_name[our_name] = @pins_by_name[datasheet_name] or raise "Pin #{datasheet_name} not found."
      end
    end

    def initialize_vars
      memories = {
        ram: ram,
        program_memory: program_memory,
        eeprom: eeprom,
      }
      @vars = self.class.variable_set.bind(memories)
    end

    def initialize_sfrs_and_nmmrs
      @sfrs = {}
      @assembly.device_info.sfrs.each do |sfr|
        @sfrs[sfr.name.to_sym] = Variable.new Storage::Register.new @processor.get_sfr(sfr.name), @sfr_memory, sfr.width
      end

      @nmmrs = {}
      @assembly.device_info.nmmrs.each do |nmmr|
        @nmmrs[nmmr.name.to_sym] = Variable.new Storage::Register.new @processor.get_nmmr(nmmr.name), @nmmr_memory, nmmr.width
      end

      @wreg = reg(:WREG)
      @stkptr = reg(:STKPTR)
    end

    public

    # Returns a Pin object if a pin by that name is found, or raises an exception.
    # @param name [Symbol] The name from the datasheet or a name specified in a
    #   call to {ClassDefinitionMethods#def_pin} in the class definition.
    # @return [Pin]
    def pin(name)
      @pins_by_name[name.to_sym] or raise ArgumentError, "Cannot find pin named '#{name}'."
    end

    # Returns a {Variable} object if a Special Function Register (SFR) or
    # Non-Memory-Mapped Register (NMMR) by that name is found.
    # If the register cannot be found, this method raises an exception.
    # @param name [Symbol] The name from the datasheet.
    # @return [Register]
    def reg(name)
      name = name.to_sym
      @sfrs[name] || @nmmrs[name] or raise ArgumentError, "Cannot find SFR or NMMR named '#{name}'."
    end

    # Returns a {Variable} object if a variable by that name is found.
    # If the variable cannot be found, this method raises an exception.
    # @return [Variable]
    def var(name)
      @vars[name.to_sym] or raise ArgumentError, "Cannot find var named '#{name}'."
    end

    # Returns a {Label} object if a program label by that name is found.
    # The name is specified in the code that defined the label.  If you are using a C compiler,
    # you will probably need to prefix the name with an underscore.
    # @return [Label]
    def label(name)
      program_file.label(name)
    end

    # Returns a hash that associates label names as Ruby symbols to {Label} objects.
    def labels
      program_file.labels
    end

    # Returns the number of instruction cycles simulated in this simulation.
    # @return [Integer]
    def cycle_count
      @simulator.stopwatch_value
    end

    # Registers a new callback to be run after every simulation step.
    # Each time the simulation takes a step, the provided block will be called.
    def every_step(&proc)
      @step_callbacks << proc
    end

    # Executes one more instruction.
    # @return nil
    def step
      @assembly.debugger_step
      @step_callbacks.each(&:call)
      nil  # To make using the ruby debugger more pleasant.
    end

    # Executes the specified number of instructions.
    # @param step_count [Integer]
    # @return nil
    def run_steps(step_count)
      step_count.times { step }
      nil  # To make using the ruby debugger more pleasant.
    end

    # Runs the simulation until one of the given conditions has been met, then
    # stops and returns the condition that was met.
    #
    #
    # Example usage in RSpec:
    #    result = run_to [:mylabel, :return], cycle_limit: 400
    #    result.should == :return
    #
    # @param conditions Each element of the conditions array should be
    #  a Proc that returns true when the condition is met, a symbol corresponding
    #  to a program label, or any other object that is a valid argument to
    #  {#convert_condition_to_proc}.
    #  If there is only one condition, you can pass it directly in as the first
    #  argument without wrapping it in an array.
    # @param opts [Hash] A hash of options.
    #  - +cycle_limit+: The maximum number of cycles to run, as an integer.
    #    It is recommended to always specify this to avoid accidentally
    #    making an infinite loop.  Note that multi-cycle instructions mean
    #    that this limit will sometimes be violated by one cycle.
    #    If none of the conditions are met by the cycle limit, an exception is raised.
    #  - +cycles+: A range of integers specifying how long you expect
    #    it to take to reach one of the conditions, for example e.g. +1000..2000+.
    #    If a condition is met before the minimum, an exception is raised.
    #    If none of the conditions are met after the maximum, an exception is
    #    raised.
    #
    #    This option is a more powerful version of +cycle_limit+, so it cannot
    #    be used at the same time as +cycle_limit+.
    # @return The condition that was met which caused the run to stop.
    def run_to(conditions, opts = {})
      conditions = Array(conditions)
      if conditions.empty?
        raise ArgumentError, 'Must specify at least one condition.'
      end

      condition_procs = conditions.map(&method(:convert_condition_to_proc))

      allowed_keys = [:cycle_limit, :cycles]
      invalid_keys = opts.keys - allowed_keys
      if !invalid_keys.empty?
        raise ArgumentError, "Unrecognized options: #{invalid_keys.join(", ")}"
      end

      if opts[:cycles] && opts[:cycle_limit]
        raise ArgumentError, 'Cannot specify both :cycles and :cycle_limit.'
      end

      start_cycle = cycle_count
      if opts[:cycles]
        raise "Invalid range: #{opts[:cycles].inspect}." unless opts[:cycles].min && opts[:cycles].max
        min_cycle = start_cycle + opts[:cycles].min
        max_cycle = start_cycle + opts[:cycles].max
        max_cycle -= 1 if opts[:cycles].exclude_end?
      elsif opts[:cycle_limit]
        max_cycle = start_cycle + opts[:cycle_limit] if opts[:cycle_limit]
      end

      # Loop until one of the conditions is satisfied.
      until (met_condition_index = condition_procs.find_index(&:call))
        if max_cycle && cycle_count >= max_cycle
          raise "Failed to reach #{conditions.inspect} after #{cycle_count - start_cycle} cycles."
        end

        step
      end

      met_condition = conditions[met_condition_index]

      if min_cycle && cycle_count < min_cycle
        raise "Reached #{met_condition.inspect} in only #{cycle_count - start_cycle} cycles " +
          "but expected it to take at least #{min_cycle - start_cycle}."
      end

      # Return the argument that specified the condition that was satisfied.
      met_condition
    end

    # Gets the address of the specified location in program memory.
    # This is a helper for processing the main argument to {#goto} and {#run_subroutine}.
    # @param location One of the following:
    #   - The name of a program label, as a symbol or string.
    #   - A {Label} object.
    #   - An integer representing the address.
    # @return [Integer]
    def location_address(location)
      case location
      when Integer         then location
      when Label           then location.address
      when Symbol, String  then label(location).address
      end
    end

    # Changes the {#pc} value to be equal to the address of the given location.
    # @param location Any valid argument to {#location_address}.
    def goto(location)
      pc.value = location_address(location)
    end

    # Runs the subroutine at the given location.  This can be useful for doing
    # unit tests of subroutines in your firmware.
    #
    # The current program counter value will be pushed onto the stack before
    # running the subroutine so that after the subroutine is done the simulation
    # can proceed as it was before.
    #
    # Example usage in RSpec:
    #   run_subroutine :calculateSum, cycle_limit: 20
    #   sum.value.should == 30
    #
    # @param location Any valid argument to {#location_address}.  It should
    #   generally point to a subroutine in program memory that will end by
    #   executing a return instructions.
    # @param opts Any of the options supported by {#run_to}.
    def run_subroutine(location, opts = {})
      stack_push pc.value
      goto location
      run_to :return, opts
    end

    # Runs the simulation for the given number of instruction cycles.
    # Note that the existence of multi-cycle instructions means that sometimes this
    # method can run one cycle longer than desired.
    # @param num_cycles [Integer]
    def run_cycles(num_cycles)
      run_to_cycle_count cycle_count + num_cycles
    end

    # Runs the simulation until the {#cycle_count} is greater than or equal to the
    # given cycle count.
    # @param count [Integer]
    def run_to_cycle_count(count)
      step while cycle_count < count
    end

    # Simulates a return instruction being executed by popping the top value off
    # of the stack and setting the {#pc} value equal to it.
    # This can be useful for speeding up your tests when you have a very slow function
    # and just want to skip it.
    def return
      if stack_pointer.value == 0
        raise 'Cannot return because stack is empty.'
      end

      # Simulate popping the stack.
      stack_pointer.value -= 1
      pc.value = @stack_memory.read_word(stack_pointer.value)
      update_top_of_stack_registers
    end

    # Generates a friendly human-readable string description of where the
    # program counter is currently using the symbol table.
    def pc_description
      program_file.address_description(pc.value)
    end

    # Pushes the given address onto the simulated call stack.
    def stack_push(value)
      if !@stack_memory.valid_address?(stack_pointer.value)
        raise "Simulated stack is full (stack pointer = #{stack_pointer.value})."
      end

      @stack_memory.write_word(stack_pointer.value, value)
      stack_pointer.value += 1
      update_top_of_stack_registers
    end

    # Gets the contents of the stack as an array of integers.
    # @return [Array(Integer)] An array of integers.
    def stack_contents
      (0...stack_pointer.value).map do |n|
        @stack_memory.read_word(n)
      end
    end

    # Returns a call stack trace representing the current state of the
    # simulation.  Printing this stack trace can help you figure out what part
    # of your code is running and why.
    # @return [StackTrace]
    def stack_trace
      # The stack stores return addresses, not call addresses.
      # We get the call addresses by subtracting the address increment,
      # which is the number of address units that each word of program memory takes up.
      addresses = stack_contents.map do |return_address|
        return_address - address_increment
      end
      addresses << pc.value
      entries = addresses.map do |address|
        StackTraceEntry.new address, program_file.address_description(address)
      end
      StackTrace.new(entries)
    end

    private

    # Update the TOSU:TOSH:TOSL registers because the simulator uses those
    # (if they exist) when simulating a return instruction.
    def update_top_of_stack_registers
      return unless @sfrs.key?(:TOSL)

      tos = if stack_pointer.value == 0
              0
            else
              @stack_memory.read_word(stack_pointer.value - 1)
            end

      reg(:TOSL).value = tos >> 0 & 0xFF
      reg(:TOSH).value = tos >> 8 & 0xFF
      reg(:TOSU).value = tos >> 16 & 0xFF if @sfrs.key?(:TOSU)
    end

    public

    def inspect
      "#<#{self.class}:0x%x, #{pc_description}, stack_pointer = #{stack_pointer.value}>" % object_id
    end

    # Converts the specified condition into a Proc that, when called, will return a
    # truthy value if the condition is satisfied.
    # This is a helper for processing the main argument to {#run_to}.
    # @param c One of the following:
    #   - The symbol +:return+.
    #     The condition will be true if the current subroutine has returned.
    #     This is implemented by looking to see whether the stack pointer has
    #     decreased one level below the level it was at when this method was called.
    #   - The name of a program label, as a symbol or string, or a
    #     {Label} object.  The condition will be true if the {#pc}
    #     value is equal to the label address.
    #   - An integer representing an address.  The condition will be true if the
    #     {#pc} value is equal to the address.
    #   - A Proc.  The Proc will be returned unchanged.
    # @return [Integer]
    def convert_condition_to_proc(c)
      case c

      when Proc
        c

      when Integer
        proc { pc.value == c }

      when :return
        current_val = stack_pointer.value
        if current_val == 0
          raise 'The stack pointer is 0; waiting for a return would be strange and might not work.'
        else
          target_val = current_val - 1
        end
        proc { stack_pointer.value == target_val }

      when Label
        convert_condition_to_proc c.address

      when String, Symbol
        convert_condition_to_proc label(c).address

      else
        raise ArgumentError, "Invalid run-termination condition #{c.inspect}"
      end
    end

    # Creates and returns a {MemoryWatcher} object configured to watch for
    # changes to RAM.  For more information, see {file:RamWatcher.md}.
    # @return [MemoryWatcher]
    def new_ram_watcher
      MemoryWatcher.new(self, @simulator.fr_memory, ram_vars + sfr_vars)
    end

    def shortcuts
      self.class::Shortcuts
    end

    # Returns the {RPicSim::ProgramFile} representing the firmware being simulated.
    # @return [ProgramFile]
    def program_file
      self.class.program_file
    end

    private

    def ram_vars
      ram_var_names = self.class.variable_set.var_names_for_memory(:ram)
      @vars.values_at(*ram_var_names)
    end

    def sfr_vars
      @sfrs.values
    end

    def address_increment
      @assembly.device_info.code_address_increment
    end
  end
end
