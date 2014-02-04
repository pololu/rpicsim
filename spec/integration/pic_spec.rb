require_relative '../spec_helper'

describe "RPicSim::Pic" do
  it "is the same as RPicSim::Sim" do
    # Pic only exists for backwards compatibility.
    expect(RPicSim::Pic).to be RPicSim::Sim
  end
end