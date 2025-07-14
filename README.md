# 32-bit-Custon-ISA-Processor
This project presents the design and implementation of a 32-bit custom processor developed in Verilog using the Xilinx Vivado design suite. The processor features a custom **Instruction Set Architecture (ISA)** that supports a wide range of operations, including arithmetic, logic, shift, memory access (load/store), and control flow (branching). The processor executes each instruction by progressing through an instruction cycle comprising four stages: Fetch, Decode, Execute, and Write-Back.

## Processor modules:
1. **memory**: This module initializes a memory space used to store both instructions and data. The memory consists of 4096 words, with each word being 32 bits wide. It supports read and write operations based on control signals provided during execution.
2. **reg_bank**: The register bank contains 16 general-purpose registers, each 32 bits wide. These registers are used for temporarily storing operands, intermediate results, and final outputs of instructions.
3. **ALU**  
The ALU (Arithmetic Logic Unit) is a combinational circuit responsible for executing instructions on operands stored in the register bank. It supports a total of **18 operations**, categorized as follows:

- **Arithmetic Operations**  
  - Addition  
  - Subtraction  
  - Multiplication  
  - Division  
  - Increment  
  - Decrement  

- **Logical Operations**  
  - Bitwise AND  
  - Bitwise OR  
  - Bitwise XOR  
  - Bitwise NOR  
  - Bitwise NAND  
  - Bitwise NOT  

- **Shift Operations**  
  - Logical Right Shift  
  - Logical Left Shift  
  - Circular Right Shift  
  - Circular Left Shift  
  - Arithmetic Right Shift  
4. **processor**: This is the top-level module that instantiates all submodules and manages the control signals necessary for instruction execution. It orchestrates the full instruction cycle of the processor architecture.

## How instructions are executed?
Each instruction is 32 bits in length and resides in the memory. Instruction execution begins with the **Fetch Cycle**, during which the instruction is fetched from memory using the **Program Counter** (PC). The instruction is then loaded into the Instruction Register (IR).

The instruction format is as follows:
1. 8 bits for the opcode
2. 8 bits for the register address
3. 16 bits for the data or memory address
   
The **ALU operations** define only register address, 8 bits each to define on which register instruction is performed and in which register to store the result. 

The **Decode Cycle** interprets the fetched instruction by decoding the opcode and determining the required operation. Corresponding control signals are then activated based on the instruction type.

The **Execute Cycle** and **Write Cycle** performs the operation specified in the instruction:
1. For arithmetic and logical instructions, operands are read from the register bank and processed by the ALU.
2. For branch instructions, the processor evaluates the branching condition and updates the PC accordingly.
3. For memory operations, the relevant memory address is accessed to read from or write to.

Finally, stores the result of the operation into the appropriate register or memory location, completing the instruction cycle.

## Instruction Set Architecture (ISA) - Opcode Table

| Mnemonic | Opcode (Hex) | Description                            |
|----------|--------------|----------------------------------------|
| `NOP`    | `0x00`       | No operation                           |
| `STORE`  | `0x01`       | Store register value to memory         |
| `LOAD`   | `0x02`       | Load value from memory to register     |
| `BUN`    | `0x03`       | Branch unconditionally                 |
| `BZ`     | `0x04`       | Branch if zero                         |
| `BP`     | `0x05`       | Branch if positive                     |
| `SII`    | `0x06`       | Skip if equal to                       |
| `ADD`    | `0x07`       | Add two registers                      |
| `SUB`    | `0x08`       | Subtract two registers                 |
| `MUL`    | `0x09`       | Multiply two registers                 |
| `DIV`    | `0x0A`       | Divide two registers                   |
| `AND`    | `0x0B`       | Bitwise AND                            |
| `OR`     | `0x0C`       | Bitwise OR                             |
| `XOR`    | `0x0D`       | Bitwise XOR                            |
| `NOR`    | `0x0E`       | Bitwise NOR                            |
| `NAND`   | `0x0F`       | Bitwise NAND                           |
| `NOT`    | `0x16`       | Bitwise NOT                            |
| `INC`    | `0x17`       | Increment value                        |
| `DEC`    | `0x18`       | Decrement value                        |
| `SR`     | `0x19`       | Logical right shift                    |
| `SL`     | `0x20`       | Logical left shift                     |
| `AR`     | `0x21`       | Arithmetic right shift                 |
| `CIR`    | `0x22`       | Circular right shift                   |
| `CIL`    | `0x23`       | Circular left shift                    |
| `HLT`    | `0x24`       | Halt the processor                     |
