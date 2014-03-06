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

  describe 'shortcuts' do
    let(:forwarded_methods) { RPicSim::Sim::BasicShortcuts::ForwardedMethods }

    it 'only has shortcuts for methods that are actually defined' do
      forwarded_methods.each do |name|
        expect(RPicSim::Sim.instance_method(name)).to be
      end
    end

    it 'has shortcuts for all the methods we want' do
      undesired_shortcuts = [
        :convert_condition_to_proc,
        :device,
        :filename,
        :inspect,
        :return,
        :shortcuts,
      ]
      missing_shortcuts = RPicSim::Sim.instance_methods(false) - forwarded_methods - undesired_shortcuts
      expect(missing_shortcuts).to be_empty
    end
  end
end
