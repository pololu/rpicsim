Making tests run faster
====

In general, an RPicSim simulation runs thousands of times slower than the device it simulates.
Simulating how your firmware behaves over time spans longer than a few milliseconds can be very slow.
This page contains some tips for making your tests run faster.

First of all, {file:UnitTesting.md unit tests} are generally very fast, so try to use unit tests as much as possible.

Consider {file:Stubbing.md stubbing} routines in your firmware that take a long time to run if the exact behavior of those routines is not important for the test.  This is explained on the {file:Stubbing.md Stubbing page}.

If your tests run slowly because the firmware is waiting for a simulated timer to advance, you might use techniques similar to stubbing in order to advance the timer by hundreds of counts at once without having simulate hundreds of processor cycles.

For the specs that are slow, use RSpec metadata to mark them as slow.
This allows you to prevent those tests from running during normal development.
For example, you could mark an individual example as slow like this:

    !!!ruby
    it "can run for a second", slow: true do
      run_cycles 4_000_000
    end

You can also mark an entire context or describe block as slow using the same syntax.
To exclude the slow tests, run `rspec` with this command:

    !!!plain
    rspec -t '~slow'

There is nothing special about the word "slow" in the example above; you can make up your own metadata tags to fit your application.