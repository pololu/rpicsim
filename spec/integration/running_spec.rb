require_relative '../spec_helper'

describe RPicSim::Sim do
  before do
    start_sim Firmware::NestedSubroutines
  end

  describe '#run_steps' do
    it 'runs the specified number of instructions' do
      run_steps 3
      pc.value.should == 0x41
    end

    it 'returns nil' do
      run_steps(3).should == nil
    end

    it 'is different than running a specified number of cycles (some steps take multiple cycles)' do
      run_steps 3
      cycle_count.should == 6
    end
  end

  describe '#run_to' do
    it 'can run to an address' do
      run_to 0x80
      pc.value.should == 0x80
      cycle_count.should == 10
    end

    it 'can run to a label' do
      run_to :ioo
      pc.value.should == 0x80
      cycle_count.should == 10
    end

    it 'can run until a return happens' do
      stkptr.value = 1
      goto :isr
      run_to :return, cycle_limit: 100
      cycle_count.should == 8
    end

    it 'can run until an arbitrary proc is fulfilled' do
      run_to Proc.new { pc.value >= 0x40 }
      pc.value.should == 0x41
    end

    it 'can take multiple conditions and returns which one was reached' do
      result = run_to [:start2, :goo]
      result.should == :goo
      pc.value.should == label(:goo).address
    end

    describe 'cycle_limit option' do
      it "does not raise an exception if the cycle_limit isn't violated" do
        run_to :goo, cycle_limit: 100
        pc.value.should == label(:goo).address
      end

      it 'raises an exception if the cycle_limit is violated' do
        expect { run_to :goo, cycle_limit: 3 }.to raise_error 'Failed to reach [:goo] after 4 cycles.'
      end

      it 'does not run at all if the cycle_limit is 0' do
        expect { run_to [:goo], cycle_limit: 0 }.to raise_error 'Failed to reach [:goo] after 0 cycles.'
        cycle_count.should == 0
      end
    end

    describe 'cycles option' do
      it 'does not raise an exception if a condition is met within the allowed range of cycles' do
        run_to :goo, cycles: 6..6
      end

      it 'raises an exception if a condition is met too soon' do
        expect { run_to [:goo, 4], cycles: 7..10 }.to raise_error 'Reached :goo in only 6 cycles but expected it to take at least 7.'
      end

      it 'raises an exception if all conditions are met too late' do
        expect { run_to [:goo, 4], cycles: 2..3 }.to raise_error 'Failed to reach [:goo, 4] after 4 cycles.'
      end
    end

    it 'gives an error if you specify no conditions' do
      expect { run_to [] }.to raise_error ArgumentError, 'Must specify at least one condition.'
    end

    it 'gives an error if you specify an invalid condition' do
      expect { run_to(Object.new) }.to raise_error ArgumentError, /Invalid run-termination condition/
    end

    it 'gives an error if you specify an unrecognized option' do
      expect { run_to 4, foo: 3 }.to raise_error ArgumentError, 'Unrecognized options: foo'
    end

    it 'gives an error if you specify both :cycles and :cycle_limit' do
      expect { run_to 4, cycles: 3..5, cycle_limit: 5 }.to raise_error ArgumentError, 'Cannot specify both :cycles and :cycle_limit.'
    end

    it 'gives an error if you try to wait for return when the stack is empty' do
      expect { run_to :return }.to raise_error 'The stack pointer is 0; waiting for a return would be strange and might not work.'
    end
  end

  describe 'run_cycles' do
    it 'runs the specified number of cycles (or a little more if there is a multi-cycle instruction)' do
      run_cycles 5
      cycle_count.should == 6  # because of a multi-cycle instruction
    end
  end

  describe 'run_to_cycle_count' do
    it 'runs until the specified cycle_count (or a little more if there is a multi-cycle instruction)' do
      run_to_cycle_count 5
      cycle_count.should == 6
      run_to_cycle_count 10
      cycle_count.should == 10
    end
  end

  describe 'run_subroutine' do
    it 'pushes the current pc value onto the stack' do
      sim.stack_push 1
      sim.stack_push 9
      goto 13
      expect { run_subroutine :foo, cycle_limit: 0 }.to raise_error
      expect(sim.stack_contents).to eq [1, 9, 13]
    end
    
    it "doesn't change the state of the stack and PC if it completes successfully" do
      sim.stack_push 1
      sim.stack_push 9
      goto 13
      run_subroutine :foo, cycle_limit: 100
      expect(sim.stack_contents).to eq [1, 9]
      expect(pc.value).to eq 13
    end
  end

end

describe 'Running on an enhanced midrange device' do
  before do
    start_sim Firmware::Test16F1826
  end
  
  describe 'run_subroutine' do
    it 'works' do
      expect(sim.stack_contents).to eq []
      run_subroutine :emptyRoutine, cycle_limit: 10
      expect(sim.stack_contents).to eq []
    end
  end
end