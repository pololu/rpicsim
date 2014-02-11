Preventing call stack overflow
====

PIC microcontrollers feature a stack implemented in hardware that keeps track of return addresses for subroutine calls.
Every time a `CALL` instruction is executed, the return address is pushed onto the stack.
Every time a `RETURN` or similar instruction is executed, the return address is popped off of the stack.
The PIC datasheets tend to refer to this as the "stack", but in RPicSim it is known as the _call stack_ in order to make it clear that this is the stack that relates to the `CALL` instruction and it is different from any kind of stack a C compiler might place in RAM for local variables.

The call stack has a limited depth that depends on the device you are using.
If your program has too many levels of nested subroutines then the call stack could overflow.
Depending on the device, a call stack overflow could cause a reset or incorrect program execution.
Therefore, it is important to avoid a call stack overflow.

RPicSim can trace all the possible paths of execution for a PIC program in order to calculate what the maximum possible call stack depth is.
You can easily add this to your RSpec tests.
Here is an example:

    !!!ruby
    describe "call stack" do
      subject(:call_stack_info) do
        RPicSim::CallStackInfo.hash_from_program_file(MySim.program_file, [0, 4])
      end

      specify "mainline code uses no more than 5 levels" do
        call_stack_info[0].max_depth be <= 5
      end

      specify "ISR code uses no more than 2 levels" do
        call_stack_info[4].max_depth.should be <= 1
      end
    end

This example is for a PIC10F322 program.
The mainline code's entry point is at address 0, and the first RSpec example makes sure that the maximum depth of subroutine calls in the mainline code is 5.
The firmware uses an interrupt and the interrupt vector is at address 4.
The second RSpec example makes sure that the ISR uses at most one level of the call stack (the ISR itself can only call one subroutine).

If the two tests above pass, then we can calculate the maximum amount of call stack space that might ever be used.  If the mainline code is at its deepest point and it is interrupted by an ISR that happens to reach its deepest point, then the call stack would have:

* 5 levels used by the mainline code.
* 1 level used by the processor itself to store the address to return to when the interrupt is done.
* 1 level used by the ISR code.

The means there can be at most 7 things stored on the call stack, which is safely below the PIC10F322's limit of 8.

Suppose RPicSim tells you that your mainline code could take 5 levels of the stack and you are not sure why.
The {RPicSim::CallStackInfo#worst_case_code_paths_filtered_report} can produce a set of example code paths that demonstrate how the maximum depth could potentially happen.
To see the report, just add a line like this:

    !!!ruby
    p call_stack_info[0].worst_case_code_paths_filtered_report

The report will be a series of code paths that look something like this:

    !!!plain
    CodePath:
    Instruction(0x0000, GOTO 0x20)
    Instruction(0x0024 = start2, CALL 0x40)
    Instruction(0x0040 = foo, CALL 0x41)
    Instruction(0x0041 = goo, CALL 0x60)
    Instruction(0x0060 = hoo, CALL 0x80)
    Instruction(0x0080 = ioo, CALL 0x100)
    Instruction(0x0100 = joo, CLRF 0x7)

This example code path shows five CALL instructions that could potentially be nested.

How it works
----

The {RPicSim::ProgramFile} class uses the MPLAB X disassembler to provide a graph with every reachable instruction in the firmware.
The {RPicSim::CallStackInfo} class traverses all possible paths through that graph from a given entry point to calculate the maximum possible call stack depth at every point in the graph.

Limitations
----

The code for disassembling in {RPicSim::ProgramFile} currently only works with the midrange and baseline PIC instruction sets.  However, it should be easy to expand it to the other instruction sets.

The algorithm is pessimistic:

* It does not try to track the runtime values of any of your program's variables in order to predict which code paths will happen.
* It cannot handle recursive functions because there is no way for it to figure out the maximum level of recursion.
* It does not know when interrupts are enabled.

All of those things are OK because they can only cause the algorithm to give an answer that is more pessimistic than reality; the reported maximum call stack depth might be higher than what is actually possible.

However, there are some things that can mess up the algorithm in a bad way and give you incorrect results:

* If you write to the PC register in order to do a computed jump, the algorithm does not currently detect that and will not correctly consider code paths coming from that instruction.
  Be careful about this, because a computed jump might be generated automatically by a C compiler.
* Similarly, it cannot handle jumps on devices that have paged memory.  In order to determine where a jump actually goes, it would need to know what page is selected by looking at the history of the program's execution.

This code is not suitable (yet) for any firmware that uses a computed jump or paged program memory.
  
This code only checks the hardware call stack; it does not check any kind of data stack that your compiler might use to store the values of local variables.  Checking that kind of stack is important, but would be much harder.