# Toast-RV32i

- Toast is a RISC-V soft core written in fully synthesizable SystemVerilog that implements a subset of the RV32I ISA.

- Goals: 

     - Produce a core that is capable of running the RV32ui unit tests from official [riscv-tests](https://github.com/riscv/riscv-tests) repo
     - Utilize synthesizable SystemVerilog features
     - Gain familiarity with Linux environment

- Stretch Goals:
     - Formal Verification
     - Interface the core with a UART peripheral and display
     some text on a PC terminal
     - Add Zicsr extension support
     - Add ISR handling



- Toast currently is capable of passing all RV32ui unit tests, however Toast has not been tested on hardware until updated here.

- Toast does not support interrupt handling, nor the CSR, FENCE, EBREAK, or ECALL instructions.


<h1> Files in this Repository </h1>

__/Documentation__
- Contains datapath diagrams and notes

__/Mem__
- Contains memory initialization hex files for riscv-tests 

__/Scripts__
- Contains shell scripts to compile, link, and generate memory files from the riscv-tests, as well as a script to run tests and dump vcd from vivado

__/Sources__
- Contains all source files for Toastcore and UART peripheral (WIP)

__/Test__
- Contains the riscv-tests, testbenches to either run an individual test or the entire battery of tests, GTKwave translate filter files/processes, and the vcd outputs for each test

<h1> Performance </h1>

|Instruction | CPI|
|------------|----|
Direct Jump (JAL) | 3
Indirect Jump (JALR) | 3
ALU reg-reg | 3
ALU reg-imm | 3
Cond. Branch (Not Taken) | 3
Cond. Branch (Taken) | 5
Memory Load | 5
Memory Store | 4



<h1> Memory Interface </h1>

Toast uses a simple memory interface driving DIN, ADDR, WE, and RST lines. The memory data bus is 32-bits wide for both instruction and data memory.

The instruction memory is word-addressable, and the data memory is byte-addressable using byte-enables.


