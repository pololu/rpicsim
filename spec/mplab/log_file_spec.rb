require 'spec_helper'

describe 'MPLAB log files' do
  # The log files were deleted near the top of spec_helper.rb, so here we test to
  # see if they have come back.

  if RPicSim::Flaws[:creates_log_files]
    specify 'do get created' do
      expect(mplab_log_files).to_not be_empty
    end
  else
    specify 'do not get created' do
      expect(mplab_log_files).to be_empty
    end
  end
end
