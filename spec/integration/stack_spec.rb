require_relative '../spec_helper'

describe 'Stack methods' do
  context 'for midrange architecture' do
    before do
      start_sim Firmware::NestedSubroutines
    end

    describe 'stkptr' do
      it 'lets us access the stack pointer' do
        run_to :ioo, cycle_limit: 100
        stkptr.value.should == 3
      end
    end
    
    describe '#stack_pointer' do
      it 'lets us access the stack pointer in a more consistent way across architectures' do
        run_to :ioo, cycle_limit: 100
        stack_pointer.value.should == 3
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
  
  context 'for PIC18 architecture' do
    before do
      start_sim Firmware::Test18F25K50
    end
    
    describe '#stack_contents' do
      specify 'holds the address of the next instruction after a CALL is executed' do
        goto :testCall
        step
        expect(sim.stack_contents).to eq [label(:testCall).address + 4]
      end

      specify 'holds the address of the next instruction after an RCALL is executed' do
        goto :testRCall
        step
        expect(sim.stack_contents).to eq [label(:testRCall).address + 2]
      end
    end
    
    describe '#stack_trace' do
      it 'decrements stack contents by 2' do
        goto :testCall
        step
        trace_addresses = sim.stack_trace.entries.collect(&:address)
        expect(trace_addresses.size).to eq 2
        expect(trace_addresses).to eq sim.stack_contents.collect { |a| a - 2 } + [pc.value]
      end
    end
  end
  
  context 'for enhanced-midrange architecture' do
    before do
      start_sim Firmware::Test16F1826
    end
    
    describe '#stack_contents' do
      it 'initially returns an empty array' do
        expect(sim.stack_contents).to be_empty
      end
    end
    
    describe '#stack_push' do
      it 'pushes a value on to the stack' do
        sim.stack_push 0x100
        expect(sim.stack_contents).to eq [0x100]
        sim.stack_push 0x101
        expect(sim.stack_contents).to eq [0x100, 0x101]
      end
    end
  end
  
end
