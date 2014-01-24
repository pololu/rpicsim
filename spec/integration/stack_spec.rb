require 'spec_helper'

describe "Stack methods" do
  before do
    start_sim Firmware::NestedSubroutines
  end
  
  describe "stkptr" do
    it "lets us access the stack pointer" do
      run_to :ioo, cycle_limit: 100    
      stkptr.value.should == 3
    end
  end

  describe "#stack_contents" do
    it "returns the addresses on the stack" do
      run_to :ioo, cycle_limit: 100
      pic.stack_contents.should == [0x23, 0x42, 0x61]
    end
  end

  describe "#stack_trace" do
    it "returns a nice stack trace object" do
      run_to :ioo, cycle_limit: 100
      st = pic.stack_trace
      sio = StringIO.new
      st.output(sio)
      sio.string.should == <<END
0x0080 = ioo
0x0060 = hoo
0x0041 = goo
0x0022 = start+0x2
END
     
    end
  end
  
end