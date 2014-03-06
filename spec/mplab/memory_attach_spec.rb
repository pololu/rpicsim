require_relative '../spec_helper'

class BasicObserver
  include com.microchip.mplab.util.observers.Observer
  attr_reader :events
  attr_reader :raw_events

  def initialize(obj)
    obj.Attach(self, nil)
    @events = []
    @raw_events = []
  end

  def Update(event)
    @raw_events << event
    @events << event_data(event)
  end
end

class MemoryObserver < BasicObserver
  def event_data(e)
    {
      type: e.EventType.to_s,
      affected: e.AffectedAddresses.map { |mr| [mr.Address, mr.Size] },
    }
  end
end

describe 'Memory.attach on the RAM memory' do
  before do
    start_sim firmware_class
    @obs = MemoryObserver.new(sim.instance_variable_get(:@simulator).fr_memory.instance_variable_get(:@memory))
  end

  let(:events) { @obs.events }
  let(:firmware_class) { Firmware::BoringLoop }
  
  it 'emits events that actually change later', flaw: true do
    # The workaround for this flaw is easy: don't hang on to event objects given to
    # us by Micrchip code.  But it's still a flaw so I want to document it.

    step
    
    # This is an event where we extracted the data from it immediately.
    event = @obs.events.first
    if RPicSim::Flaws[:fr_memory_attach_useless]
      event.should == {:type=>'MEMORY_CHANGED', :affected=>[[0, 128]]}
    else
      event.should == {:type => 'MEMORY_CHANGED', :affected => [[2, 1], [5, 1], [7, 1], [10, 2], [16, 1], [37, 1]]}
    end
    
    # This is an event where we waited until the step was done to extract data.    
    # It's bad that the two are different.
    raw_event = @obs.event_data(@obs.raw_events.first)
    raw_event.should == {:type => 'MEMORY_CHANGED', :affected => []}
  end

  context 'for a boring loop' do
    let(:firmware_class) { Firmware::BoringLoop }

    if !RPicSim::Flaws[:fr_memory_attach_useless]
    
      it 'has usable output' do
        changed_pcl_and_pclath = {:type=>'MEMORY_CHANGED', :affected=>[[2, 1], [10, 1]]}
        boring_out_of_sync = {:type=>'OUT_OF_SYNCH', :affected=>[[0, 128]]}
        typical_events = [changed_pcl_and_pclath, boring_out_of_sync]
      
        events.should == []
        step
        events.should == [
          {:type=>'MEMORY_CHANGED', :affected=>[[2, 1], [5, 1], [7, 1], [10, 2], [16, 1], [37, 1]]},
          boring_out_of_sync,
        ]
        events.clear
        step
        events.should == typical_events
        events.clear
        step
        events.should == typical_events
        events.clear
        step
        events.should == typical_events
        events.clear
        step
        events.should == typical_events
      end
      
    else
    
      it 'has useless output in MPLAB X 1.95 and above', flaw: true do
        all_memory_changed = {:type=>'MEMORY_CHANGED', :affected=>[[0, 128]]}
      
        events.should == []
        step
        events.should == [all_memory_changed]  # bad
        events.clear
        step
        events.should == [all_memory_changed]  # bad
        events.clear
        step
        events.should == [all_memory_changed]  # bad
        events.clear
        step
        events.should == [all_memory_changed]  # bad
        events.clear
        step
        events.should == [all_memory_changed]  # bad
        events.clear
      end
      
    end
  end
  
end
