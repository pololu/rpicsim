require_relative '../spec_helper'

describe RPicSim::RSpec::PersistentExpectations do
  subject do
    o = Object.new
    o.extend described_class
    allow(o).to receive(:expect) { |a| expect(a) }
    o
  end

  describe '#expecting' do
    it 'returns the current hash of expectations' do
      subject.expectations.should == {}
    end
  end

  describe '#expecting' do
    it 'adds to the hash' do
      @a = []
      @b = 'abc'
      empty_matcher = be_empty
      subject.expecting @a => empty_matcher, @b => eq('abc')
      subject.expectations.should == { @a => empty_matcher, @b => eq('abc') }
    end
  end

  describe '#check_expecations' do
    it 'just returns nil when the expectations match' do
      subject.expecting [] => be_empty
      expect(subject.check_expectations).to eq nil
    end

    it "raises the right error when expectations don't match" do
      subject.expecting [] => be_empty, [1] => be_empty
      expect { subject.check_expectations }.to raise_error RSpec::Expectations::ExpectationNotMetError
    end
  end

end
