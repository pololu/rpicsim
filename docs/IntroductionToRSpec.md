Introduction to RSpec
====

[RSpec](http://rspec.info/) is a testing tool for the Ruby programming language that allows you to write automated tests.
RSpec provides great ways to combine code from similar tests, provides good error messages, and encourages you to specify exactly what you are testing.

The main documentation for RSpec can be found from the project's website at [rspec.info](http://rspec.info/), but I think it is not very easy to follow.  This page goes over the most important things you should know about RSpec.

File structure
----

The recommended way to set up your RSpec tests is to put them inside a directory named `spec`, as discussed in {file:GettingStarted.md Getting Started}.  When you run the `rspec` command, RSpec will look for all the files in `spec` and its subdirectories that have a name ending in `_spec.rb`.


Example groups and examples
----

Each spec file contains one or more _example groups_, which are defined using RSpec's `describe` or `context` commands.  For example:

    !!!ruby
    describe "my device" do
       # examples of how your device should behave go here
    end

You can have nested example groups:

    !!!ruby
    describe "my device" do
      context "when RA1 is held high" do
        # examples go here
      end
    end

The outer-most example must be a `describe`, not a `context`.

An _example_ is the basic unit of an RSpec spec.  Examples are defined using the `it` or `specify` commands inside an example group:

    !!!ruby
    describe "my device" do
      it "toggles RA2 often" do
        # code to test the toggling goes here
      end
    end

The strings passed to `describe`, `context`, `it`, and `specify` are optional, but are used to generate helpful error messages and documentation.  If an example fails then a string about the expected behavior is produced by concatenating all the provided strings, from outermost to innermost.

Expectations
----

In general, an RSpec example consists of some code to set up the situation being tested, and some code that called an _expectation_ that defines the expected outcome.

RSpec has two special syntaxes for writing expectations: the "expect" syntax and the "should" syntax.  The "expect" syntax is the favored, so this manual will only use "expect".  The basic structure of an expectation is:

    !!!ruby
    expect(actual).to matcher(expected)
    expect(actual).to_not matcher(expected)

* `expect` is a method defined by RSpec which you can use inside your tests.
* `actual` is a pseudo-name for the object being tested, which is usually the output of the system under test or part of the system under test.  This is passed as the first argument to `matcher`.
* `to` and `to_not` are special methods defined by RSpec.
* `matcher` is a pseudo-name for a method that can produce a matcher object.  The matcher object decides whether the expectation was met or not.  In the example below, `matcher` is `eq`, which is one of the [built-in matchers that RSpec provides](https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers).  Most RSpec examples only need to use the `eq` matcher.
* `expected` is a pseudo-name for an argument you would pass to `matcher`.  Often it represents an expected value, state, or property being tested.

Here is a concrete, runnable example:

    !!!ruby
    describe "the number 5" do
      it "when added to one is six" do
        num = 1 + 5
        expect(num).to eq 6
      end
    end

The number 6 is passed as the first argument to `eq` to make an equality matcher that tests whether objects are equal to 6.  The code about will add 1 to 5 and then expect it to equal 6.

If the expectation fails, an exception is raised and the example stops executing.

A common practice in RSpec is to have just one expectation per example.
This helps you organize your examples and makes it clear to the reader what each example is supposed to be testing.
However, it is not always practical because it makes the specs slower; there will be more examples and the code that gets the system into the the situation to be tested has to be run more times than necessary.

For more information, see the [RSpec Expectations documentation](https://www.relishapp.com/rspec/rspec-expectations/docs).

Before and after hooks
----

Inside an example group, RSpec lets you define before and after hooks.  A before hook can either run once before all the examples in the group or run before each example.  For example:

    !!!ruby
    describe "my device" do
      before(:all) do
        # Code here runs one time only, before all of the
        # examples in this group.
      end

      before do
        # Code here runs before each example in this group.
        # This is equivalent to before(:each).
      end

      # examples go here

      after do
        # Code here runs after each example.
        # This is equivalent to after(:each).
      end

      after(:all) do
        # Code here runs after all examples in the group
        # are done.
      end
    end

In RPicSim, you will usually have a before hook that starts the simulation of your firmware.

If you have a context referring to your system being in a particular state, a before hook is a great place for the code that actually gets the system into that state.
The code in that hook can easily be reused in multiple examples that test different things about the state.
For example:

    !!!ruby
    describe "my car" do
      context "in second gear at 20 MPH" do
        before do
          car.speed = 20
          car.gear = 2
        end

        it "has a lot of torque" do
          expect(car.torque).to eq 7
        end

        it "has a high RPM" do
          expect(car.rpm).to eq 9001
        end
      end
    end

Instance variables
----

In Ruby, a variable whose name starts with `@` behaves specially and is called an _instance variable_.  Instance variables defined in one part of an example (e.g. a before hook) can be accessed in later parts.

For example:

    describe "foo" do
      before do
        @car = Car.new
        @wheel = car.wheels.find_by_location(:front, :left).first
      end

      it "is round" do
        expect(@wheel).to be_round
      end

    end

Let variables
----

Another way to define a variable in RSpec is to use the `let` syntax.
The `let` method should be called inside an example group.
The first argument is the name of a variable to define.
The `let` method is passed a block that computes the value of the variable, and the block will be called if the value of the variable is ever needed.
In other words, `let` variables are lazily evaluated.

The example below shows how a `let` variable could be useful for making your tests more readable; I only had to write the number 2 once.  In this case, `let` allows us to separate the description of the expected behavior (the car can shift gears) from the arbitrary value (2) that we used to test it.

    !!!ruby
    describe "my car" do
      let(:gear) { 2 }

      it "can shift gears" do
        car.gear = gear
        expect(car.gear).to eq gear
      end
    end

These `let` variables can also be a useful way to share data or bits of code between different examples.

    !!!ruby
    describe "my car's front left wheel" do
      let(:car) { Car.new }
      let(:wheel) { car.wheels.find_by_location(:front, :left).first }

      it "is round" do
        expect(wheel).to be_round
      end

      it "is a wheel" do
        expect(wheel).to be_a_kind_of Car::Wheel
      end
    end


Blocks in RSpec
----

Whenever you see code between the Ruby keywords `do` and `end`, or between `{` and `}`, that code is inside a Ruby _block_.
A block is a chunk of executable code that can be easily created, passed around, and called like a method.

In RSpec, the blocks you pass to the `describe` and `context` methods are executed right away.
However, the blocks passed to the `it`, `specify`, `before`, `after`, and `let` commands serve to define how the examples will be executed, and those blocks do not get called until later after RSpec has chosen which examples to run.

You cannot read a spec file like you would read a simple step-by-step program.
Any given block could be called once, multiple times, or never depending on the situation.


Shared examples
----

Sometimes you will be tempted to copy a set of examples from one context to another, because the system should behave the same in both contexts.  However, your tests will be long and hard to maintain if you have too much duplicated code.  In this situation, you should consider making a _shared example group_.  See the [RSpec shared examples](https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples) documentation for more information.