# If an example fails, store some diagnostic information about the state of the PIC
# so we can print it later.
RSpec.configure do |config|
  config.after(:each) do
    if @pic && example.exception
      example.metadata[:pic_cycle_count] = @pic.cycle_count
      example.metadata[:pic_stack_trace] = @pic.stack_trace
    end
  end
end

require 'rspec/core/formatters/base_text_formatter'
RSpec::Core::Formatters::BaseTextFormatter

# We enhance rspec's backtrace so it will also show us the stack trace of the
# simulated PIC, if available.  These monkey patches are broken up into three
# different functions so you can easily customize any of them without messing up
# the other ones.
class RSpec::Core::Formatters::BaseTextFormatter
  alias dump_backtrace_without_pic_diagnostics dump_backtrace

  def dump_backtrace(example)
    dump_backtrace_without_pic_diagnostics(example)
    dump_pic_diagnostics(example)
  end
  
  def dump_pic_diagnostics(example)
    dump_pic_cycle_count(example)
    dump_pic_stack_trace(example)
  end
  
  def dump_pic_cycle_count(example)
    cycle_count = example.metadata[:pic_cycle_count] or return
    output.puts long_padding
    output.printf long_padding + "Simulated PIC cycle count: %d\n", cycle_count
  end
  
  # Looks inside the metadata for the given RSpec example to see if a PIC stack
  # trace was recorded.  If so, it outputs it with the appropriate indentation.
  def dump_pic_stack_trace(example)
    pic_stack_trace = example.metadata[:pic_stack_trace] or return
    output.puts long_padding
    output.puts long_padding + "Simulated PIC stack trace:"
    pic_stack_trace.output(output, long_padding)
  end
end