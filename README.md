# RPicSim: Ruby PIC<sup>®</sup> simulator interface

The RPicSim library provides an interface to the MPLAB<sup>®</sup> X PIC<sup>®</sup> simulator that allows you to write simulator-based automated tests of PIC firmware.
RPicSim is written in the [Ruby language](http://ruby-lang.org) and runs on [JRuby](http://jruby.org).
It can be used in any type of JRuby application, and it has bindings that make it especially convenient to use with the [RSpec](http://rspec.info) testing framework.
RPicSim is free to use and does not require any external hardware.

With RPicSim, you can write tests for your PIC firmware in the Ruby language.  Here is an example integration test that simulates input and output on the device's pins:

```ruby
it "continuously mirrors" do
  main_input.set false
  run_cycles 10
  expect(main_output).to be_driving_low

  main_input.set true
  run_cycles 10
  expect(main_output).to be_driving_high
end
```

Here is an example unit test written with RPicSim that tests a single subroutine in the firmware:

```ruby
it "adds 70 to 22" do
  addend1.value = 70
  addend2.value = 22
  run_subroutine :addition, cycle_limit: 100
  expect(sum.value).to eq 92
end
```

Simulator-based testing has many advantages over testing in hardware:

* Simulator-based unit tests can help catch bugs sooner.
* You can debug your firmware without having to connect an oscilloscope or add special debugging signals.
* The tests are inherently deterministic.
* The tests usually require no extra code to be added to the firmware.

RPicSim has features that allow you to:

* Simulate signals on inputs pins.
* Read the state of output pins.
* Run small parts of your code in isolation.
* Read and write from variables and special function registers (SFRs).
* Monitor all writes to RAM.
* Run assertions at every step of a simulation.

For some applications, RPicSim can also analyze the firmware and verify that the call stack will never overflow.

RPicSim is distributed as a Ruby gem named `rpicsim`.

RPicSim has been tested with MPLAB X v1.85, v1.90, v1.95, and v2.00.
However, it uses a lot of undocumented and internal features of the Microchip Java libraries, so it will probably need to be updated as new versions of MPLAB X are released.

RPicSim is not intended to replace formal specifications, code reviews, and rigorous testing of your firmware on actual hardware.
RPicSim is just another tool that can make it easier to write and test the firmware.

The names Microchip, PIC, MPLAB, and MPASM are trademarks of Microchip Technology Incorporated.  RPicSim is not written, supported, or endorsed by Microchip.

For complete documentation, see the [RPicSim API documentation](http://www.davidegrayson.com/hold/rpicsim/_index.html) and the [RPicSim manual](http://www.davidegrayson.com/hold/rpicsim/file.Manual.html).

The gem is not on RubyGems.org yet, but you can [download it from here](http://www.davidegrayson.com/hold/rpicsim-1.0.1.gem) and install it with:

    gem install rpicsim-1.0.1.gem

The source code is temporarily hosted on a [private github repository](https://github.com/shicholas/rpicsim) provided by Nick Shook.