require_relative 'search'
require 'set'

module RPicSim
  # This class helps analyze programs to see whether it is possible for them
  # to overflow the call stack, which is limited to a small number of levels on
  # many PIC microcontrollers.
  # It traverses the {Instruction} graph provided by a {ProgramFile}
  # from a given root node and for each reachable instruction determines the
  # maximum possible call stack depth when that instruction starts executing,
  # relative to how deep the call stack depth was when the root instruction
  # started.
  #
  # Here is an example of how you would use this to check the call stack depth
  # in a program that has one interrupt vector at address 4 inside an RSpec test.
  # Of course, you should adjust the numbers to suit your application:
  #
  #     infos = CallStackInfo.hash_from_program_file(program_file, [0, 4])
  #     infos[0].max_depth.should <= 5  # main-line code should take at most 5 levels
  #     infos[4].max_depth.should <= 1  # ISR should take at most 1 stack level
  #
  # Additionally, it can generate reports of all different ways that the maximum
  # call stack depth can be achieved, which can be helpful if you need to reduce
  # your maximum stack depth.
  class CallStackInfo
    # For each of the given root instruction addresses, generates a {CallStackInfo}
    # report.  Returns the reports in a hash.
    #
    # @param program_file (ProgramFile)
    # @param root_instruction_addresses Array(Integer)  The program memory
    #   addresses of the entry vectors for your program.  On a midrange device, these
    #   are typically 0 for the main-line code and 4 for the interrupt.
    # @return [Hash(address => CallStackInfo)]
    def self.hash_from_program_file(program_file, root_instruction_addresses)
      infos = {}
      root_instruction_addresses.each do |addr|
        infos[addr] = from_root_instruction(program_file.instruction(addr))
      end
      infos
    end

    # Generates a {CallStackInfo} from the given root instruction.
    # This will tell you the maximum value the call stack could get to for a
    # program that starts at the given instruction with an empty call stack
    # and never gets interrupted.
    def self.from_root_instruction(root)
      new(root)
    end

    # The maximum call stack depth for all the reachable instructions.
    # If your program starts executing at the root node and the call stack
    # is empty, then (not accounting for interrupts) the call stack will
    # never exceed this depth.
    #
    # A value of 0 means that no subroutine calls a possible; a value of
    # 1 means that at most one subroutine call is possible at any given time,
    # and so on.
    #
    # @return (Integer)
    attr_reader :max_depth

    # @return (Instruction) The root instruction that this report was generated from.
    attr_reader :root

    # Generates a {CallStackInfo} from the given root instruction.
    def initialize(root)
      @root = root
      generate
      @max_depth = @max_depths.values.max
    end

    private

    def generate
      @max_depths = { @root => 0 }
      @back_links = Hash.new { [] }
      instructions_to_process = [root]
      while !instructions_to_process.empty?
        instruction = instructions_to_process.pop
        instruction.transitions.reverse_each do |transition|
          ni = transition.next_instruction
          prev_depth = @max_depths[ni]
          new_depth = @max_depths[instruction] + transition.call_depth_change

          if new_depth > 50
            raise "Recursion probably detected.  Maximum call depth of #{ni} is at least #{new_depth}."
          end

          if prev_depth.nil? || new_depth > prev_depth
            @max_depths[ni] = new_depth
            instructions_to_process << ni
            @back_links[ni] = []
          end

          if new_depth == @max_depths[ni]
            @back_links[ni] << instruction
          end
        end
      end
    end

    public

    # Returns all the {Instruction}s that have the worse case possible call stack depth.
    # @return [Array(Instruction)]
    def instructions_with_worst_case
      @max_depths.select { |instr, depth| depth == @max_depth }.map(&:first).sort
    end

    # Returns all the {Instruction}s that are reachable from the given root.
    # @return [Array(Instruction)]
    def reachable_instructions
      @max_depths.keys
    end

    # Check the max-depth data hash for consistency.
    def double_check!
      reachable_instructions.each do |instr|
        depth = @max_depths[instr]

        instr.transitions.each do |transition|
          next_instruction = transition.next_instruction
          if @max_depths[next_instruction] < @max_depths[instr] + transition.call_depth_change
            raise 'Call stack info double check failed: %s has max_depth %d and leads (%d) to %s with max_depth %d.' %
              [instr, depth, transition.call_depth_change, next_instruction, @max_depths[next_instruction]]
          end
        end

      end
    end

    # Returns an array of {CodePath}s representing all possible ways that the call stack
    # could reach the worst-case depth.  This will often be a very large amount of data,
    # even for a small project.
    # @return [Array(CodePath)]
    def worst_case_code_paths
      instructions_with_worst_case.sort.flat_map do |instruction|
        code_paths(instruction)
      end
    end

    # Returns a filtered version of {#worst_case_code_paths}.
    # Filters out any code paths that are just a superset of another code path.
    # For each instruction that has a back trace leading to it, it just returns
    # the code paths with the smallest number of interesting instructions.
    # @return [Array(CodePath)]
    def worst_case_code_paths_filtered
      all_code_paths = worst_case_code_paths

      # Filter out code path that are just a superset of another code path.
      previously_seen_instruction_sequences = Set.new
      code_paths = []
      all_code_paths.sort_by(&:count).each do |code_path|
        seen_before = (1..code_path.instructions.size).any? do |n|
          subsequence = code_path.instructions[0, n]
          previously_seen_instruction_sequences.include? subsequence
        end
        if !seen_before
          previously_seen_instruction_sequences << code_path.instructions
          code_paths << code_path
        end
      end

      # For each instruction that has a code path leading to it, pick out
      # the shortest code path (in terms of interesting instructions).
      code_paths = code_paths.group_by { |cp| cp.instructions.last }.map do |instr, code_paths|
        code_paths.min_by { |cp| cp.interesting_instructions.count }
      end

      code_paths
    end

    # Returns a nice report string of all the {#worst_case_code_paths_filtered}.
    # @return [String]
    def worst_case_code_paths_filtered_report
      s = ''
      worst_case_code_paths_filtered.each do |code_path|
        s << code_path.to_s + "\n"
        s << "\n"
      end
      s
    end

    # @return [Array(CodePaths)] all the possible code paths that lead to the given instruction.
    def code_paths(instruction)
      code_paths = []
      Search.depth_first_search_simple([[instruction]]) do |instrs|
        prev_instrs = @back_links[instrs.first]

        if prev_instrs.empty?
          # This must be the root node.
          if instrs.first != @root
            raise "This instruction is not the root and has no back links: #{instrs}."
          end

          code_paths << CodePath.new(instrs)
          []   # don't search anything from this node
        else
          # Investigate all possible code paths that could get to this instruction.
          # However, exclude code paths that have the same instruction twice;
          # otherwise we get stuck in an infinite loop.
          (prev_instrs - instrs).map do |instr|
            [instr] + instrs
          end
        end
      end
      code_paths
    end

    def inspect
      "#<#{self.class}:root=#{@root.inspect}>"
    end

    # This is a helper class for {CallStackInfo}.  It wraps an array of {Instruction} objects
    # representing an execution path from one part of the program (usually the entry vector or
    # the ISR vector) to another part of the program.
    # It has method for reducing this list of instructions by only showing the interesting ones.
    class CodePath
      include Enumerable

      # An array of {Instruction}s that represents a possible path through the program.
      # Each instruction in the list could possibly execute after the previous one.
      attr_reader :instructions

      # A new instance that wraps the given instructions.
      # @param instructions Array(Instruction) The instructions to wrap.
      def initialize(instructions)
        @instructions = instructions.freeze
      end

      # Iterates over the wrapped instructions by calling <tt>each</tt> on the underlying array.
      # Since this class also includes <tt>Enumerable</tt>, it means you can use any of the
      # usual methods of Enumerable (e.g. <tt>select</tt>) on this class.
      def each(&proc)
        instructions.each(&proc)
      end

      # Returns the addresses of the underlying instructions.
      def addresses
        instructions.map(&:address)
      end

      # Returns an array of the addresses of the interesting instructions.
      def interesting_addresses
        interesting_instructions.map(&:address)
      end

      # Returns just the interesting instructions, as defined by {#interesting_instruction?}.
      #
      # @return [Array(Integer)]
      def interesting_instructions
        @instructions.select.each_with_index do |instruction, index|
          next_instruction = @instructions[index + 1]
          interesting_instruction?(instruction, next_instruction)
        end
      end

      # Returns true if the given instruction is interesting.  An instruction is
      # interesting if you would need to see it in order to understand the path
      # program has taken through the code and understand why the call stack
      # could reach a certain depth.
      #
      # * The first and last instructions are interesting.
      # * A branch that is taken is interesting.
      # * A subroutine call is interesting.
      def interesting_instruction?(instruction, next_instruction)
        if instruction == @instructions.first || instruction == @instructions.last
          return true
        end

        transition = instruction.transition_to(next_instruction)

        if transition.call_depth_change >= 1
          # This edge represents a function call so it is interesting.
          return true
        end

        if transition.non_local?
          # This edge represents a goto, so that is interesting
          # because you need to know which gotos were taken to understand
          # a code path.  If seeing the skip is annoying we could
          # suppress that by adding more information to the edge.
          return true
        end

        # Everything else is not interesting.

        # We are purposing deciding that skips are not interesting.
        # because if you are trying to understand the full code path
        # it is obvious whether any given skip was taken or not, as long
        # as you know which calls and gotos were taken.

        false
      end

      # Returns a multi-line string representing this execution path.
      def to_s
        "CodePath:\n" +
          interesting_instructions.join("\n") + "\n"
      end
    end
  end
end
