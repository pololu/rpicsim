require_relative '../spec_helper'

describe RPicSim::StackTrace do
  it 'can take entries and output them in reverse order with padding' do
    entry_data = [[3, 'three'], [4, 'four'], [5, 'five']]
    entries = entry_data.collect do |addr, desc|
      RPicSim::StackTraceEntry.new(addr, desc)
    end
    stack_trace = RPicSim::StackTrace.new(entries)
    sio = StringIO.new
    stack_trace.output(sio, '  ')
    sio.string.should == <<END
  five
  four
  three
END
  end
end

describe RPicSim::StackTraceEntry do
  subject(:entry) do
    described_class.new(6, 'six')
  end

  it 'stores the address' do
    entry.address.should == 6
  end

  it 'stores the description' do
    entry.description.should == 'six'
  end

  it 'returns the description in response to to_s' do
    entry.to_s.should == 'six'
  end
end
