describe "cooldown" do
  before do
    start_sim Firmware::LongDelay
    
    # Stub the "bigDelay" function because it takes a long time to run.
    # Also, count how many times it was called.
    @big_delay_count = 0
    every_step do
      if pc.value == label(:bigDelay).address
        @big_delay_count += 1
        sim.return
      end
    end
  end
  
  context "when the room is cool" do
    before do
      hot.value = 0
    end
  
    it "only does one big delay" do
      run_subroutine :cooldown, cycle_limit: 100
      expect(@big_delay_count).to eq 1
    end
  end

  context "when the room is hot" do
    before do
      hot.value = 1
    end
  
    it "does two big delays" do
      run_subroutine :cooldown, cycle_limit: 100
      expect(@big_delay_count).to eq 2
    end
  end
end