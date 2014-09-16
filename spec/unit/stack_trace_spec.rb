require_relative '../spec_helper'

describe RPicSim::StackTrace do
  it 'can take entries and output them in reverse order with padding' do
    entry_data = [[3, 'three'], [4, 'four'], [5, 'five']]
    entries = entry_data.map do |addr, desc|
      RPicSim::StackTraceEntry.new(addr, desc)
    end
    stack_trace = RPicSim::StackTrace.new(entries)
    sio = StringIO.new
    stack_trace.output(sio, '  ')
    expect(sio.string).to eq <<END
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
    expect(entry.address).to eq 6
  end

  it 'stores the description' do
    expect(entry.description).to eq 'six'
  end

  it 'returns the description in response to to_s' do
    expect(entry.to_s).to eq 'six'
  end
end
