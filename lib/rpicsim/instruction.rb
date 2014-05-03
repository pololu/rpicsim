module RPicSim
  # Instances of this class represent a particular instruction at a particular
  # address in program memory.  This class takes low-level information about a
  # disassembled instruction and produces high-level information about what that
  # instruction is and how it behaves.
  #
  # Instances of this class have links to the other instructions that the instruction
  # could lead to, so the instances form a graph.  This graph is traversed by
  # classes like {CallStackInfo} to get useful information about the firmware.
  class Instruction
    include Comparable

    # The program memory address of the instruction.
    # For PIC18s this will be the byte address.
    # For other PIC architectures, it will be the word address.
    # @return (Integer)
    attr_reader :address

    # The opcode as a capitalized string (e.g. "MOVLW").
    # @return (String)
    attr_reader :opcode

    # The operands of the instruction as a hash like { "k" => 92 }.
    # @return (Hash)
    attr_reader :operands

    # The number of program memory address units that this instruction takes.
    # The units of this are the same as the units of {#address}.
    # @return (Integer)
    attr_reader :size

    # A line of assembly language that would represent this instruction.
    # For example "GOTO 0x2".
    # @return (String)
    attr_reader :string

    # Creates a new instruction.
    def initialize(mplab_instruction, address, address_increment, instruction_store)
      @address = address
      @instruction_store = instruction_store
      @address_increment = address_increment

      if mplab_instruction == :invalid
        @valid = false
        @size = @address_increment
        @string = '[INVALID]'
        return
      end

      @valid = true
      @opcode = mplab_instruction.opcode
      @operands = mplab_instruction.operands
      @string = mplab_instruction.instruction_string

      @size = mplab_instruction.compute_size(address_increment)
      raise "Invalid size #{@size} for #{inspect}" if ![1, 2, 4].include?(@size)

      properties = Array case mplab_instruction.opcode
      when 'ADDFSR'
      when 'ADDLW'
      when 'ADDWF'
      when 'ADDWFC'
      when 'ANDLW'
      when 'ANDWF'
      when 'ASRF'
      when 'BC'     then [:conditional_relative_branch]
      when 'BCF'
      when 'BN'     then [:conditional_relative_branch]
      when 'BNC'    then [:conditional_relative_branch]
      when 'BNN'    then [:conditional_relative_branch]
      when 'BNOV'   then [:conditional_relative_branch]
      when 'BNZ'    then [:conditional_relative_branch]
      when 'BRA'    then [:relative_branch]
      when 'BRW'    then [:control_ender]    # Hard to predict
      when 'BSF'
      when 'BTG'
      when 'BTFSC'  then [:conditional_skip]
      when 'BTFSS'  then [:conditional_skip]
      when 'BZ'     then [:conditional_relative_branch]
      when 'CALL'   then [:call]
      when 'CALLW'  then [:control_ender]    # Hard to predict
      when 'CPFSEQ' then [:conditional_skip]
      when 'CPFSGT' then [:conditional_skip]
      when 'CPFSLT' then [:conditional_skip]
      when 'CLRF'
      when 'CLRW'
      when 'CLRWDT'
      when 'COMF'
      when 'DAW'
      when 'DECF'
      when 'DECFSZ' then [:conditional_skip]
      when 'DCFSNZ' then
      when 'GOTO'   then [:goto]
      when 'INCF'
      when 'INCFSZ' then [:conditional_skip]
      when 'INFSNZ' then [:conditional_skip]
      when 'IORLW'
      when 'IORWF'
      when 'LFSR'
      when 'LSLF'
      when 'LSRF'
      when 'MOVIW'
      when 'MOVWI'
      when 'MOVLB'
      when 'MOVLP'
      when 'MOVLW'
      when 'MOVWF'
      when 'MOVF'
      when 'MOVFF'
      when 'MULLW'
      when 'MULWF'
      when 'NEGF'
      when 'NOP'
      when 'OPTION'
      when 'PUSH'
      when 'POP'
      when 'RCALL'  then [:relative_call]
      when 'RESET'  then [:control_ender]
      when 'RETFIE' then [:control_ender]
      when 'RETLW'  then [:control_ender]
      when 'RETURN' then [:control_ender]
      when 'RLCF'
      when 'RLF'
      when 'RLNCF'
      when 'RRCF'
      when 'RRF'
      when 'RRNCF'
      when 'SETF'
      when 'SLEEP'
      when 'SUBLW'
      when 'SUBWF'
      when 'SUBWFB'
      when 'SWAPF'
      when 'TBLRD*'
      when 'TBLRD*+'
      when 'TBLRD*-'
      when 'TBLRD+*'
      when 'TBLWT*'
      when 'TBLWT*+'
      when 'TBLWT*-'
      when 'TBLWT+*'
      when 'TRIS'
      when 'TSTFSZ' then [:conditional_skip]
      when 'XORLW'
      when 'XORWF'
      else
        raise "Unrecognized opcode #{mplab_instruction.opcode} " +
          "(#{address_description(address)}, operands #{mplab_instruction.operands.inspect})."
      end

      modules = {
        conditional_skip: ConditionalSkip,
        conditional_relative_branch: ConditionalRelativeBranch,
        relative_branch: RelativeBranch,
        relative_call: RelativeCall,
        goto: Goto,
        control_ender: ControlEnder,
        call: Call,
      }

      properties.each do |p|
        mod = modules[p]
        if !mod
          raise ArgumentError, "Invalid property: #{p.inspect}."
        end
        extend mod
      end
    end

    # Compares this instruction to another using the addresses.  This means you can
    # call +.sort+ on an array of instructions to put them in order by address.
    def <=>(other)
      address <=> other.address
    end

    # Human-readable string representation of the instruction.
    def to_s
      "Instruction(#{@instruction_store.address_description(address)}, #{@string})"
    end

    def inspect
      "#<#{self.class}:#{@instruction_store.address_description(address)}, #{@string}>"
    end

    # Returns info about all the instructions that this instruction could directly lead to
    # (not counting interrupts, returns, and not accounting
    # at all for what happens after the last word in the main program memory is executed).
    # For instructions that pop from the call stack like RETURN and RETFIE, this will be
    # the empty array.
    # @return [Array(Transition)]
    def transitions
      @transitions ||= generate_transitions
    end

    # Returns the transition from this instruction to the specified instruction
    # or nil if no such transition exists.
    # @return Transition
    def transition_to(instruction)
      @transitions.find { |t| t.next_instruction == instruction }
    end

    # Returns the addresses of all the instructions this instruction could directly lead to.
    # @return [Array(Integer)]
    def next_addresses
      transitions.map(&:next_address)
    end

    private

    # For certain opcodes, this method gets over-written.
    def generate_transitions
      [ advance(1) ]
    end

    # Makes a transition representing the default behavior: the microcontroller
    # will increment the program counter and execute the next instruction in memory.
    def advance(num)
      transition(address + num * size)
    end

    def transition(addr, attrs={})
      Transition.new(self, addr, @instruction_store, attrs)
    end

    def valid?
      @valid
    end

    private

    # Returns the address indicated by the operand 'k'.
    # k is assumed to be a word address and it is assumed to be absolute
    # k=0 is word 0 of memory, k=1 is word one.
    # We need to multiply by the address increment because on PIC18
    # program memory addresses are actually byte-based instead of word-based.
    def k_address
      operands[:k] * @address_increment
    end

    def n_address
      address + @address_increment * (operands[:n] + 1)
    end

    def relative_k_address
      address + @address_increment * (operands[:k] + 1)
    end

    def relative_target_address
      if operands[:k]
        relative_k_address
      elsif operands[:n]
        n_address
      else
        raise 'This instruction does not have fields k or n.'
      end
    end

    ### Modules that modify the behavior of the instruction. ###

    # This module is mixed into any {Instruction} that represents a goto or branch.
    module Goto
      def generate_transitions
        # Assumption: The GOTO instruction's k operand is absolute on all architectures
        [ transition(k_address, non_local: true) ]
      end
    end

    # This module is mixed into any {Instruction} that represents a conditional skip
    # A conditional skip is an instruction that might cause the next instruction to be
    # skipped depending on some condition.
    module ConditionalSkip
      def generate_transitions
        [ advance(1), advance(2) ]
      end
    end

    # This module is mixed into any {Instruction} that represents a return from a subroutine
    # or a RESET instruction.
    module ControlEnder
      def generate_transitions
        []
      end
    end

    # This module is mixed into any {Instruction} that represents a subroutine call.
    module Call
      def generate_transitions
        [ transition(k_address, call_depth_change: 1), advance(1) ]
      end
    end

    module RelativeCall
      def generate_transitions
        [ transition(n_address, call_depth_change: 1), advance(1) ]
      end
    end

    module ConditionalRelativeBranch
      def generate_transitions
        [ transition(n_address, non_local: true), advance(1) ]
      end
    end

    module RelativeBranch
      def generate_transitions
        [ transition(relative_target_address, non_local: true) ]
      end
    end

    class Transition
      attr_reader :previous_instruction
      attr_reader :next_address

      def initialize(previous_instruction, next_address, instruction_store, attrs)
        @previous_instruction = previous_instruction
        @next_address = next_address
        @instruction_store = instruction_store
        @attrs = attrs
      end

      def next_instruction
        @next_instruction ||= @instruction_store.instruction(next_address)
      end

      def non_local?
        @attrs.fetch(:non_local, false)
      end

      def call_depth_change
        @attrs.fetch(:call_depth_change, 0)
      end

    end
  end
end
