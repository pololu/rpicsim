require_relative '../spec_helper'

describe RPicSim::Sim do
  before do
    start_sim Firmware::Test18F25K50
  end

  describe '#inspect' do
    it 'returns a short string' do
      str = sim.inspect
      expect(str).to be_a_kind_of String
      expect(str.size).to be < 160
    end
  end
end