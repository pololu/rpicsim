require_relative '../spec_helper'

class SimStub
  module Shortcuts
    def stub_shortcut
    end
  end

  def shortcuts
    Shortcuts
  end

  def every_step
  end
end

describe 'rspec' do
  describe 'BePredicate matchers' do
    # These tests pass in RSpec 2.x thanks to our monkey patch,
    # and work in RSpec 3.x without needing a monkey patch.

    it "provides a nicer error message when something like 'not be_empty' fails" do
      expect { expect([1]).to be_empty }.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        'expected `[1].empty?` to return true, got false'
      )
    end

    it "provides a nicer error message when something like 'be_empty' fails" do
      expect { expect([]).to_not be_empty }.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        'expected `[].empty?` to return false, got true'
      )
    end

  end

  describe 'simulation diagnostics' do
    let(:stack_trace) do
      stack_trace = double('stack_trace')
      allow(stack_trace).to receive(:output) { |io, padding| io.puts padding + 'StackTrace' }
      stack_trace
    end

    let(:info) do
      { sim_stack_trace: stack_trace, sim_cycle_count: 111 }
    end

    let(:example) do
      double('example', metadata: info)
    end

    if defined?(RSpec::Core::Notifications)
      # Rspec 3.x
      it 'monkeypatches FailedExampleNotification in RSpec 3.x' do
        fen = RSpec::Core::Notifications::FailedExampleNotification
        begin
          # RSpec 3.3.0 and later
          exception_presenter = nil
          n = fen.new(example, exception_presenter)
        rescue ArgumentError => ex
          raise unless ex.message =~ /struct size differs/

          # Before RSpec 3.3.0
          n = fen.new(example)
        end
        expect(n).to receive(:fully_formatted_without_sim_diagnostics).and_return('')
        expect(n.fully_formatted).to eq <<-END

     Simulation cycle count: 111

     Simulation stack trace:
     StackTrace
        END
      end
    else
      # RSpec 2.x
      it 'monkeypatches BaseTextFormatter to add diagnostics in RSpec 2.x' do
        sio = StringIO.new
        btf = RSpec::Core::Formatters::BaseTextFormatter.new(sio)
        expect(btf).to receive(:dump_backtrace_without_sim_diagnostics)
        btf.dump_backtrace(example)

        expect(sio.string).to eq <<-END

     Simulation cycle count: 111

     Simulation stack trace:
     StackTrace
      END
      end
    end
  end

  describe 'shortcuts' do
    2.times do |n|
      specify 'are only available after calling start_sim' do
        # This makes sure that the effect of the 'extend' we use to add
        # shortcuts really does go away at the end of the example.
        # We add this test 2 times in order to make sure that one example
        # does not pollute the next.
        expect(self).to_not respond_to :run_to
        expect(self).to_not respond_to :stub_shortcut
        start_sim SimStub
        expect(self).to respond_to :run_to
        expect(self).to respond_to :stub_shortcut
      end
    end
  end
end
