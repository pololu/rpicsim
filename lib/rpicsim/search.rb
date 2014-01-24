module RPicSim
  module Search
    # Performs a depth first search.
    # No measures are taken to avoid processing the same node multiple
    # times, so this is only suitable for acyclic graphs.
    # Every time a node is processed, it will be yielded as the first
    # and only argument to the block.
    #
    # This is used by {CallStackInfo#backtraces} to search the instruction
    # graph backwards in order to find backtraces for a given instruction.
    def self.depth_first_search_simple(root_nodes)
      unprocessed_nodes = root_nodes.reverse
      while !unprocessed_nodes.empty?
        node = unprocessed_nodes.pop
        nodes = yield node
        unprocessed_nodes.concat(nodes.reverse)
      end
    end
  end
end