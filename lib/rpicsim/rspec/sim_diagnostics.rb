# If an example fails, store some diagnostic information about the state of the
# simulation so we can print it later.

module RPicSim::RSpec::SimDiagnostics
  def self.store_diagnostics(example, sim)
    if sim.respond_to? :cycle_count
      example.metadata[:sim_cycle_count] = sim.cycle_count
    end
    if sim.respond_to? :stack_trace
      example.metadata[:sim_stack_trace] = sim.stack_trace
    end
  end

  def self.write_diagnostics(example, output, padding)
    write_cycle_count(example, output, padding)
    write_sim_stack_trace(example, output, padding)
  end

  # Looks inside the metadata for the given RSpec example to see if a
  # simulation stack trace was recorded.  If so, it outputs it with the
  # appropriate indentation.
  def self.write_sim_stack_trace(example, output, padding)
    sim_stack_trace = example.metadata[:sim_stack_trace] or return
    output.puts
    output.puts padding + 'Simulation stack trace:'
    sim_stack_trace.output(output, padding)
  end

  def self.write_cycle_count(example, output, padding)
    cycle_count = example.metadata[:sim_cycle_count] or return
    output.puts
    output.printf padding + "Simulation cycle count: %d\n", cycle_count
  end
end

RSpec.configure do |config|
  config.after(:each) do
    ex = if RSpec.respond_to?(:current_example)
           RSpec.current_example  # RSpec 3.x and 2.99
         else
           example # RSpec 2.x
         end
    if @sim && ex.exception
      RPicSim::RSpec::SimDiagnostics.store_diagnostics(ex, @sim)
    end
  end
end

if defined?(RSpec::Core::Notifications)
  # RSpec 3.x

  require 'stringio'
  class RSpec::Core::Notifications::FailedExampleNotification
    alias_method :fully_formatted_without_sim_diagnostics, :fully_formatted
    def fully_formatted(*args)
      formatted = fully_formatted_without_sim_diagnostics(*args)
      sio = StringIO.new
      padding = '     '
      RPicSim::RSpec::SimDiagnostics.write_diagnostics(example, sio, padding)
      formatted << sio.string
    end
  end

else
  # RSpec 2.x

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
      RPicSim::RSpec::SimDiagnostics.write_diagnostics(example, output, long_padding)
    end
  end

end
