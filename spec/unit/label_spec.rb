require_relative '../spec_helper'

describe RPicSim::Label do
  let(:label) do
    described_class.new(:foo, 0x123)
  end

  it 'stores the name' do
    expect(label.name).to eq :foo
  end

  it 'stores the address' do
    expect(label.address).to eq 0x123
  end

  it 'returns the address for #to_i' do
    expect(label.to_i).to eq 0x123
  end

  it 'has a nice to_s method' do
    expect(label.to_s).to eq '<Label foo address=0x123>'
  end

end
