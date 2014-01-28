RAM watcher
====

When writing a {file:UnitTesting.md unit test} for some part of your firmware, you should probably test any RAM variable that the code is supposed to write to, and make sure that it contains the correct value after the code executes.
However, you should also try to make sure that your code does not write to any other parts of memory; it should only write to the places that you were expecting it to write to.

RPicSim's _ram watcher_ lets you see all the places in RAM (including SFRs) that were written by your code.
It detects writes to RAM even if the underlying RAM value didn't change.
For example, if your program runs a `clrf x` instruction, the RAM watcher will detect this even if `x` was already equal to 0.

Also, it detects writes from instructions like "`movf x, F`", which is usually not desired.
That instruction affects the STATUS register and allows you to see if `x` is zero, but it should not affect `x` if it is a normal variable in RAM.
However, that instruction technically counts as a read from `x` and a write of the same value back to `x`, so the RAM watcher detects the write and will report it.

Please note that the RAM watcher works well in MPLAB X 1.85 and 1.90 but the latest versions of MPLAB X have a flaw that makes the RAM watcher useless.
For more information, see {file:Flaws.md}.

The RAM watcher has two important methods:

* The {RPicSim::MemoryWatcher#writes writes} method provides a hash representing all the writes that have been recorded.
  Each key of the hash is the name of the variable or SFR that was written to, or just the address that was written to if the write was to an unrecognized location in memory.
  The values of the hash are the final value that the item had after the last write.
  If a subroutine under test writes to the same variable twice, the RAM watcher will only report about the last write.
* The {RPicSim::MemoryWatcher#clear clear} method erases all previous records.

For example, to test the 16-bit addition routine from the {file:Variables.md Variables page} with the RAM watcher, you could write:

    !!!ruby
    it "adds x to y and stores the result in z" do
      x.value = 70
      y.value = 22
      step; pic.ram_watcher.clear
      run_subroutine :addition, cycle_limit: 100
      expect(pic.ram_watcher.writes).to eq({z: 92})
    end

The third line in the example above, which clears the RAM watcher's records after stepping once, is necessary because the RAM watcher actually detects the writes that occurred to RAM in the lines above, even though those writes came from Ruby code.

The RAM watcher is an instance of {RPicSim::MemoryWatcher}.

Filters
----

The  {RPicSim::MemoryWatcher} class contains some special code to filter out reports about registers that are always changing, like `PCL` and `STATUS`.
It also contains some special code to filter out spurious reports of writes that happen on the very first step of the simulation.
Both of these filters might need to be updated to properly support your particular PIC (and your version of MPLAB X).