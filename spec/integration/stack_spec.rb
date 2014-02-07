require_relative '../spec_helper'

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
      sim.stack_contents.should == [0x23, 0x42, 0x61]
    end
  end

  describe "#stack_trace" do
    it "returns a nice stack trace object" do
      run_to :ioo, cycle_limit: 100
      st = sim.stack_trace
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

  describe "#stack_push" do
    it "pushes addresses onto the stack" do
      sim.stack_push 0x123
      sim.stack_push 0x22
      sim.stack_contents.should == [0x123, 0x22]
    end

    it "raises an error when the stack his been filled" do
      8.times { sim.stack_push 1 }
      expect { sim.stack_push 2 }.to raise_error "Simulated stack is full (stack pointer = 8)."
    end
  end

end
