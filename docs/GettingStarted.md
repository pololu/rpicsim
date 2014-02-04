Quick-start guide
====

This guide should help you get started with RPicSim.
It is assumed that you are familiar with some PIC firmware development environment and are able to compile your firmware to a COF or HEX file.
By the end of this guide, you will have a suite of automated simulator-based tests for the firmware.

Installing Prerequisites
----

First, on a computer running Windows, install RPicSim and the software it requires:

1. Install [MPLAB X](http://www.microchip.com/pagehandler/en-us/family/mplabx/).  RPicSim uses the Microchip Java classes from MPLAB X.
2. Install the latest version of [JRuby](http://jruby.org/).
3. Run the command `jgem install rpicsim rspec`.  This will install the latest versions of RPicSim and [RSpec](http://rspec.info/) from [RubyGems.org](http://rubygems.org/).

Set up your directories
----

You should set up your PIC development environment so that it creates a COF or HEX file inside a directory named "dist".
The file does not need to be at the top level of "dist"; it can be in any subdirectory found inside "dist".
This requirement is due to a limitation in the MPLAB X code.

Next, make a directory called "spec" for the tests you are going to write.  You can put that directory anywhere, but my preferred directory structure looks like this:

    project_dir
    |-- firmware
    |   |-- asm and c source files
    |   `-- dist
    `-- spec
        |-- *_spec.rb
        `-- spec_helper.rb

Writing your first test
----

The convention for RSpec is that all the specs live in the "spec" directory and have a name ending with `_spec.rb`.  In the spec directory, create a file named `firmware_spec.rb`.  You can rename it later.  In `firmware_spec.rb`, write:


    !!!ruby
    require_relative 'spec_helper'
    
    describe "the firmware" do
      before do
        start_sim MySim
      end

      specify "program counter changes every step for the first 100 steps" do
        100.times do
          last_pc_value = pc.value
          step
          expect(pc.value).to_not eq last_pc_value
        end
      end
    end

This sets up a dummy test that runs the simulation for 100 steps and verifies that the program counter (the address of the next instruction to execute) changes each time.  This test would fail if the firmware went into a one-instruction loop in the first 100 instructions.

To someone who is new to Ruby, RSpec, and RPicSim, understanding the code above might be pretty hard.
More information can be found by reading further in this manual; this page is just meant to help you get started, and a long explanation of this code would slow down people who already know what they are doing but just need a quick reminder of how to get started.

We have not yet told RPicSim where to find the firmware file.  To do this, make a new file named `spec_helper.rb` in the `spec` directory.  In `spec/spec_helper.rb`, write:

    !!!ruby
    require 'rpicsim/spec_helper'
    
    class MySim < RPicSim::Pic
      device_is "PIC10F322"
      filename_is File.dirname(__FILE__) + "/../firmware/dist/default/production/firmware_dir.production.cof"
    end

Edit the `device_is` and `filename_is` lines to match your actual device and the path to its COF file.  The file specified here can either be COF or HEX, but COF is recommended because it allows convenient access to the variables, functions, and labels defined in the firmware.

Eventually you should rename the `MySim` class to something more specific.  I like to name the simulation class by concatenating the project name with `Sim`.

To run the spec, go to your shell and run the command `rspec` from the directory that contains `spec`.  In the example directory structure above, you would need to be inside the `firmware` directory when you run `rspec`.  If all goes well, the output from `rspec` should look like:

    .

    Finished in 0.006 seconds
    1 example, 0 failures

RSpec is telling us that it found our one example that tests the program counter for the first 100 steps, and that it passed.  You now have have an automated simulator-based test for your firmware and you are ready to add more.

More information about how to use RPicSim can be found in the other sections of {file:Manual.md this manual}.