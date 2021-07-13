# Toast-RV32i

- Toast is a RISC-V soft core written in fully synthesizable SystemVerilog that implements a subset of the RV32I ISA, WIP until updated here.

- Toast does not support interrupt handling, nor the CSR, FENCE, EBREAK, or ECALL instructions.

- Objectives: 

     - Produce a core that is capable of running the RV32ui unit tests from official [riscv-tests](https://github.com/riscv/riscv-tests) repo
     - Utilize synthesizable SystemVerilog features
     - Gain familiarity with Linux environment

<h1> Files in this Repository </h1>

__/Documentation__
- Contains datapath diagrams and notes

__/Mem__
- Contains memory initialization files for IMEM as well as dump files for each riscv-test

__/Scripts__
- experimental 

__/Sources__
- Contains ToastCore.sv and all submodules

__/Test__
- Testbenches and riscv-tests

<h1> Performance </h1>
-  will be updated as more instructions are tested


|Instruction | CPI|
|------------|----|
Direct Jump (JAL) | <>
ALU reg-reg | 3
ALU reg-imm | 3
Cond. Branch | 3
Memory Load | <>
Memory Store | <>
Indirect Jump (JALR) | <>


<h1> Memory Interface </h1>

![Xilinx Dual-port RAM](./Documentation/dpr.png)

Toast uses a simple memory interface based on that of Xilinx dual-port block memory in dual-port RAM configuration. It
drives DIN, ADDR, WE, and RST.


