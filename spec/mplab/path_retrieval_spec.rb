require_relative '../spec_helper'

describe "PathRetrieval" do
  it "chops off the drive letter so it can only find things on the C drive", flaw: true do
    # This means that MPLAB X must always be on the C drive.
    retrieval = com.microchip.mplab.open.util.pathretrieval.PathRetrieval 
    path = retrieval.getPath(RPicSim::Mplab::DocumentLocator.java_class)
    
    path.should start_with "/"   # This is bad if we are in Windows.

    # Even though the path is messed up, java.io.File can handle it.
    # I think that it considers "/" to be "C:/".
    # JRuby does not like the path though, if you are in Windows.
    java.io.File.new(path).exists().should == true
  end
end
