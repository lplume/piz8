# piz8: A Simple 8-bit Stack-Based Virtual Machine

**piz8** is an educational 8-bit stack-based virtual machine (VM) implemented in Lua. It is designed to execute simple bytecode instructions and serves as a learning tool for those interested in the fundamentals of virtual machines and assembly-like programming. While **piz8** is a "toy" project and may have limitations, it can be a useful starting point for individuals looking to delve into the world of virtual machines. However, please note that the author, while enthusiastic, is not an expert in VM programming. For more robust and feature-rich virtual machine experiences, consider exploring projects like **uxn**, a versatile virtual machine and programming environment.

## A Note from the Creator

I want to clarify that I'm not an expert in VM programming. This project, **piz8**, is the result of my personal interest and the time I've devoted to learning. While there are more comprehensive VMs like [UXN](https://wiki.xxiivv.com/site/uxn.html) available, **piz8** represents my contribution to the field of virtual machines. It may not be flawless, but it's a project driven by my curiosity and love for exploration.

I've worked on **piz8** independently during my free time, experimenting with various ideas and code. It's just a small part of the diverse world of virtual machines, and I encourage you to explore other options as well. If you decide to delve into **piz8**, I'm here to assist and eager to hear about your experiences.

To all fellow enthusiasts and inquisitive minds, enjoy your journey with **piz8** and the vast realm of virtual machines.

## Features

- 8-bit instruction set for compact bytecode
- Basic math operations
- Comparison operations
- Bitwise operations
- Jump instructions for control flow (JMP, JIT)
- Stack-based architecture for operand storage
- Simple assembler (ASSEMBL8) for generating bytecode

## Usage

1. **Writing Programs**: Use the ASSEMBL8 assembler to write programs in the assembly language and generate bytecode for the piz8 VM. You can compile to a ROM using the pizzassemblua assembler.

    ```shell
    lua pizzemblua.lua listing.asm8 output.rom
    ```

2. **Running Programs**: Load the generated rom into the piz8 VM and execute your programs.

    ```shell
    lua runner.lua output.rom
    ```

Please note that you need Lua installed to run both the assembler and the piz8 VM.

# ASSEMBL8 Assembly Language

**ASSEMBL8** is a straightforward assembly language designed for the piz8 VM. In ASSEMBL8, instructions are written in postfix notation, which means that operands are placed before the operators. The stack in the piz8 VM follows a Last-In-First-Out (LIFO) structure, with the exception of the 'DAT' opcode. The 'DAT' opcode pushes the next byte onto the stack, allowing for data storage. Data pushed onto the stack is automatically wrapped around to fit within the 8-bit word size of the piz8 VM, ensuring consistent behavior for arithmetic and bitwise operations.

Here's an example ASSEMBL8 code that calculates the sum of numbers from 10 down to 1 and leaves the result on the stack:

```asm8
DAT 0x0A DUP

:WHILE
    DAT 0x01 SUB
    DUP ROT ADD
    SWP DUP
:WHILE JIT

POP END
```

## Stack Manipulation Opcodes

- **[0x00] DAT:** Push the specified value onto the stack.

- **[0x01] INC:** Increment the top element of the stack by 1.

- **[0x02] POP:** Pop the top element from the stack.

- **[0x03] SWP:** Swap the positions of the top two elements on the stack.

- **[0x04] ROT:** Rotate the positions of the top three elements on the stack to the left, wrapping around.

- **[0x05] DUP:** Duplicate the top element of the stack and push the duplicate onto the stack.

- **[0x06] OVR:** Duplicate the second element from the top of the stack and push it onto the stack.

## Arithmetic Opcodes

- **[0x20] ADD:** Add the top two elements of the stack, wrapping around to fit within an 8-bit word size.

- **[0x21] SUB:** Subtract the top element of the stack from the second element, wrapping around to fit within an 8-bit word size.

- **[0x22] MUL:** Multiply the top two elements of the stack, wrapping around to fit within an 8-bit word size.

- **[0x23] DIV:** Divide the second element from the top of the stack by the top element, wrapping around to fit within an 8-bit word size.

## Comparison and Conditional Opcodes

- **[0x10] EQU:** Push 0x01 onto the stack if the top two elements on the stack are equal, or 0x00 otherwise.

- **[0x11] NEQ:** Push 0x01 onto the stack if the top two elements on the stack are not equal, or 0x00 otherwise.

- **[0x12] GTH:** Push 0x01 onto the stack if the second element from the top is greater than the top element on the stack, or 0x00 otherwise.

- **[0x13] LTH:** Push 0x01 onto the stack if the second element from the top is less than the top element on the stack, or 0x00 otherwise.

## Bitwise Operation Opcodes

- **[0x30] AND:** Perform a bitwise AND operation between the top two elements of the stack, wrapping around.

- **[0x31] OOR:** Perform a bitwise OR operation between the top two elements of the stack, wrapping around.

- **[0x32] XOR:** Perform a bitwise XOR operation between the top two elements of the stack, wrapping around.

## Control Flow Opcodes

- **[0x40] END:** Terminate the execution of the piz8 virtual machine.

- **[0x41] JMP:** Jump to the specified address (relative to the current program counter).

- **[0x42] JIT:** Jump to the specified address (relative to the current program counter) if the condition on the top of the stack is not equal to 0.

### Labeling for Jumps

To specify labels for jumps, you can use a colon (:) followed by the label name in your assembly code. For example:

```asm8
:TOLABEL
... other code
:TOLABEL JMP
```

## Credits

The piz8 project owes a debt of gratitude to the following individuals and projects:

- The 100 rabbits collective, particularly the remarkable uxn project and the thriving ecosystem around it. You guys are legends! Your work has been a tremendous inspiration.
- Valuable discussions and brainstorming with:
- [MediumInvader](https://github.com/mediuminvader)
- [Mellon85](https://github.com/mellon85)
- [OverflowSith](https://github.com/overflowsith)
- A special thanks to chatGPT 3.5 for its contribution.

Without these contributions and inspirations, piz8 could have never come to fruition.

## Similar Projects

Explore these mature and well-established virtual machines:

- [Uxn Official Repository](https://git.sr.ht/~rabbits/uxn): The official repository for Uxn, a minimal stack-based virtual machine designed for small systems.

- [CHIP-8 on Wikipedia](https://en.wikipedia.org/wiki/CHIP-8): Wikipedia's page on CHIP-8, an interpreted programming language for 8-bit microcomputers.

- [PICO-8 Official Website](https://www.lexaloffle.com/pico-8.php): The official website for PICO-8, a fantasy console for making, sharing, and playing tiny games and other computer programs.

## Contributions and Conduct

**Contributions Welcome:** If you're interested in enhancing **piz8**, I encourage your involvement! Whether you're keen on resolving issues, introducing new features, sharing innovative ideas, or suggesting code improvements, your contributions are invaluable to the project's advancement. Don't hesitate to open issues to report problems or propose enhancements.

I embrace constructive discussions and foster a welcoming and respectful environment. Please be aware that I maintain a strict zero-tolerance policy for mean-spirited comments. Let's collaborate to improve **piz8** and create an even more enriching learning experience for all.