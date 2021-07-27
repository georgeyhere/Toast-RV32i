# Toast-RV32i

- Toast is a RISC-V soft core written in Verilog that implements a subset of the [RV32I ISA version 2.2](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf).

- Goals: 

     - Produce a core that is capable of running the RV32ui unit tests from official [riscv-tests](https://github.com/riscv/riscv-tests) repo
     - Gain familiarity with open-source verification tools 
     - Gain familiarity with Linux environment 

- Stretch Goals:
     - Memory-mapped I/O and UART peripheral
     - Add Zicsr extension support
     - Add ISR handling
     - Formal Verification



- Toast currently is capable of passing all RV32ui unit tests, however Toast has not been tested on hardware until updated here.

- Toast does not support interrupt handling, nor the CSR, FENCE, EBREAK, or ECALL instructions.

- There is a version of Toast that passes all unit tests that is written in SystemVerilog and that has passed synthesis with no errors at commit c77c9e9. 
  All source code has since been converted to Verilog to better work with the tools.

<h1> Files in this Repository </h1>

__Makefile__

Run ```make alltests``` to compile, link and convert riscv-tests to hex memory files and run the entire battery of tests. 
Run ```make alltest_vcd``` to run all tests and generate a vcd file.

Memory generation requires a 32-bit riscv-unknown-elf toolchain installed at /opt/riscv32i, as well as [elf2hex](https://github.com/sifive/elf2hex). Testbench is ran using Icarus Verilog. See the Makefile targets for more details.

__/docs__
- Contains datapath diagrams and notes, wip

__/scripts__
- Contains shell scripts to compile, link, and generate memory files from the riscv-tests, as well as a script to run tests and dump vcd from vivado

__/rtl__
- Contains all source files for Toastcore and UART peripheral (WIP)

__/test__
- Contains the riscv-tests, testbench, and GTKwave translate filter files/processes


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


