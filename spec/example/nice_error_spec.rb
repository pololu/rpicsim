require_relative '../spec_helper'

# This helps us generate the nice error message for RSpecIntegration.md.
# Just comment out the "if false" at the very bottom

describe "my firmware" do
  before do
    start_sim Firmware::NestedSubroutines
  end
  
  it "crashes" do
    expecting stkptr => satisfy { |s| s.value < 5 }
    run_cycles 1000
  end
end if false
