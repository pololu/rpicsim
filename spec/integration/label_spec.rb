require_relative '../spec_helper'

describe 'Labels' do
  before do
    start_sim Firmware::Addition
  end

  describe '#label' do
    context 'for an existing label' do
      subject { label(:addition) }

      it 'is a RPicSim::Label' do
        subject.should be_a_kind_of RPicSim::Label
      end

      it 'had the right name' do
        subject.name.should == :addition
      end

      it 'has the right address' do
        subject.address.should == 0
      end
    end

    context 'for a non-existent label' do
      it '#label provides a useful error message' do
        expect { label(:bad) }.to raise_error "Cannot find label named 'bad'."
      end

      it '#label provides a very useful error message for wrong names that start with a right name' do
        expect { label(:additional) }.to raise_error "Cannot find label named 'additional'.  " \
          'MPASM truncates labels.  You might have meant: addition.'
      end
    end

  end

end
