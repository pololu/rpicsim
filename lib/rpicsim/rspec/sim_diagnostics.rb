# If an example fails, store some diagnostic information about the state of the
# simulation so we can print it later.
RSpec.configure do |config|
  config.after(:each) do
    if @sim && example.exception
      if @sim.respond_to? :cycle_count
        example.metadata[:sim_cycle_count] = @sim.cycle_count
      end
      if @sim.respond_to? :stack_trace
        example.metadata[:sim_stack_trace] = @sim.stack_trace
      end
    end
  end
end

require 'rspec/core/formatters/base_text_formatter'
RSpec::Core::Formatters::BaseTextFormatter

# We enhance rspec's backtrace so it will also show us the stack trace of the
# simulation, if available.  These monkey patches are broken up into three
# different functions so you can easily customize any of them without messing up
# the other ones.
class RSpec::Core::Formatters::BaseTextFormatter
  alias_method :dump_backtrace_without_sim_diagnostics, :dump_backtrace

  def dump_backtrace(example)
    dump_backtrace_without_sim_diagnostics(example)
    dump_sim_diagnostics(example)
  end

  def dump_sim_diagnostics(example)
    dump_sim_cycle_count(example)
    dump_sim_stack_trace(example)
  end

  def dump_sim_cycle_count(example)
    cycle_count = example.metadata[:sim_cycle_count] or return
    output.puts long_padding
    output.printf long_padding + "Simulation cycle count: %d\n", cycle_count
  end

  # Looks inside the metadata for the given RSpec example to see if a
  # simulation stack trace was recorded.  If so, it outputs it with the
  # appropriate indentation.
  def dump_sim_stack_trace(example)
    sim_stack_trace = example.metadata[:sim_stack_trace] or return
    output.puts long_padding
    output.puts long_padding + 'Simulation stack trace:'
    sim_stack_trace.output(output, long_padding)
  end
end
