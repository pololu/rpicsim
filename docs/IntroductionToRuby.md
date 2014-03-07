Introduction to Ruby
====

RPicSim, and the tests that it enables you to write, are written in the {http://www.ruby-lang.org Ruby programming language}.  From ruby-lang.org:

> Ruby is a dynamic, open source programming language with a focus
> on simplicity and productivity. It has an elegant syntax
> that is natural to read and easy to write.

Instead of using the standard Ruby interpreter (known as MRI), RPicSim uses {http://jruby.org JRuby} in order to gain access to the Java classes that come with MPLAB X.

This manual comes with plenty of concrete, usable examples that you can start with even if you do not know Ruby.
You should be able to accomplish a lot with RPicSim by just copying the examples in this manual, without any specific study of the Ruby language.
However, knowing Ruby will allow you to condense repetitive parts of your tests, enable you to express complex concepts, and make it much easier to troubleshoot problems.

If you are new to Ruby, it would be a good idea to spend an afternoon perusing the [Documentation page on ruby-lang.org](https://www.ruby-lang.org/en/documentation/).
If you want more, there are many books you can buy that teach Ruby.
If you have any particular questions, try searching Google and then try asking on [StackOverflow](http://www.stackoverflow.com).
Your question will probably be answered within hours, but remember to provide all the necessary information in your first post (see [SSCCE.org](http://www.sscce.org)).


Symbols
----

Whenever you see a colon followed by a word in Ruby, such as `:all`, that is called a {http://www.ruby-doc.org/core/Symbol.html Symbol}.
Symbols are a part of the Ruby language.
They are like strings, but the main difference is that they are not mutable; they cannot be changed after they have been made.
RPicSim almost always uses symbols instead of strings to represent names of things.


Method calls
----

Ruby does not require parentheses around method arguments.
The following code retrieves the `sim` object and calls its `run_cycles` method with an argument of 250:

    !!!ruby
    sim.run_cycles 250


Hashes
----

Ruby has a built-in hash table implementation called {http://www.ruby-doc.org/core/Hash.html Hash}.
A hash can hold any type of Ruby object as keys and values.

Here is some example code that makes a hash that associates the symbol `:cycle_limit` to the number 500:

    !!!ruby
    hash = { :cycle_limit => 500 }

Since the key is a symbol, we can simplify this using special Ruby syntax:

    hash = { cycle_limit: 500 }
    
Multiple pairs can be separated by commas:

    !!!ruby
    hash = { temperature: 30, humidity: 10 }

Values can be read or written after the hash is created:
    
    !!!ruby
    hash = {}
    hash[:cycle_limit] = 500
    hash[:cycle_limit]        # returns 500
    
Ruby has a special syntax for passing a hash as the last argument of a method call; you do not need to write the brackets:

    !!!ruby
    sim.run_to :loopDone, cycle_limit: 44

    
Blocks
----

Whenever you see code between the Ruby keywords `do` and `end`, or between `{` and `}`, that code is inside a Ruby _block_.
A block is a chunk of executable code that can be easily created, passed around, and called like a method.
Any given block could be called once, multiple times, or never, depending on the situation.

For example, here is some code that passes a black to a method called `foo_method`.
The block prints "hello world" to the standard output.

    !!!ruby
    foo_method do
      puts "hello world"
    end

Depending on how `foo_method` behaves, this code could output "hello world" any number of times or not at all.
Also, `foo_method` might store the block in an object and call it at some later point in the program.