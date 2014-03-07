Memories
====

RPicSim uses the {RPicSim::Memory} class to provide access to the RAM, EEPROM, and program memory of the simulated device.
This is useful if you want to interact with variables and data structures in your firmware that are too complex to be handled by RPicSim's {file:Variables.md} feature, like strings, structs, and buffers.

RAM and EEPROM
----

To get the {RPicSim::Memory Memory} object that represents RAM, call {RPicSim::Sim#ram}.
To get the {RPicSim::Memory Memory} object that represents EEPROM, call {RPicSim::Sim#eeprom}.
The two main methods to use on these objects are:

* `read_byte(address)`: This method takes a byte address and returns the value of that byte.
* `write_byte(address, value)`: This method takes a byte address and a value between 0 and 255, and writes the value to the specified byte.

For example, if you are using RPicSim's {file:RSpecIntegration RSpec integration} you can read and write from `ram` like this:

    ram.write_byte(0x200, 0x80)
    expect(ram.read_byte(0x200)).to eq 0x80


Program memory
----

To get the {RPicSim::Memory Memory} object that represents program memory, call {RPicSim::Sim#program_memory}.
In addition to letting you access the main part of program memory which contains the program, this object also allows access to the configuration words and user ID words.
The program memory is also known as flash, ROM, and code space.

The program memory object behaves differently depending on whether your are simulating a PIC18 device or a non-PIC18 device, as described below.

### Program memory on a non-PIC18 devices

On non-PIC18 devices, the program memory is divided into _words_ that are either 12 bits wide or 14 bits wide.
In RPicSim, non-PIC18 program memory addresses are always specified as _word addresses_.
For example, the address 0 corresponds to the first _word_, while the address 1 corresponds to the second word.
The {RPicSim::Memory Memory} object provides two methods for reading and writing from these words:

* `read_word(address)`: This method takes a word address and returns the value of that word.
* `write_word(address, value)`: This method takes a word address and a numerical value, and writes the value to the specified word.

The program memory on a non-PIC18 device can also be thought of as a series of bytes, and it is often represented this way in HEX files.
Each word can be thought of as two consecutive bytes, with the lower 8 bits residing in the first byte and upper 4 bits or 6 bits residing in the second byte.
The valid range of values for the second byte, therefore, is limited.

The {RPicSim::Memory Memory} object provides two methods for reading and writing the least-significant bytes of the words in program memory:

* `read_byte(address)`: This method takes a _word_ address and returns the lower 8 bits of that word, ignoring the upper bits.
* `write_byte(address)`: This method takes a _word_ address and a value between 0 and 255 and writes the value to the lower 8 bits of that word, leaving the upper bits unchanged.

Since these methods take word addresses instead of byte addresses, they cannot access the upper bits of a program memory word.


### Program memory on PIC18 devices

On PIC18 devices, the program memory is divided into 16-bit words.
Since each word can hold exactly two bytes, the program memory is often treated as a series of bytes in development tools.
In RPicSim, PIC18 program memory addresses are always specified as _byte addresses_.

The {RPicSim::Memory Memory} object provides two methods for reading and writing words from program memory:

* `read_word(address)`: This method takes a byte address and returns the value of the 2-byte word starting at that address.
* `write_word(address, value)`: This method takes a byte address and a numerical value, and writes the value to the 2-byte word starting at the specified address.

If you supply an odd address to `read_word` or `write_word`, the operation will apply to two bytes that are actually from two different words.

The {RPicSim::Memory Memory} object provides two methods for reading and writing bytes from program memory:

* `read_byte(address)`: This method takes a _byte_ address and returns the value of that byte.
* `write_byte(address)`: This method takes a _byte_ address and a value between 0 and 255 and writes the value to that byte, leaving other bytes unchanged.