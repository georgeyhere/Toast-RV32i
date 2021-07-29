# Toast-RV32i

- Toast is a RISC-V soft core written in Verilog that implements a subset of the [RV32I ISA version 2.2](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf).

![top](https://github.com/georgeyhere/Toast-RV32i/blob/main/docs/images/toast_top.jpg)

- Documentation: https://toast-core.readthedocs.io/en/latest/

- Goals: 

     - Produce a core that is capable of running the RV32ui unit tests from official [riscv-tests](https://github.com/riscv/riscv-tests) repo
     - Gain familiarity with open-source tools 

- Stretch Goals:
     - Memory-mapped I/O and UART peripheral
     - Zicsr extension support
     - ISR handling
     - UVM and/or Formal Verification

- Toast currently is capable of passing all RV32ui unit tests and has passed timing at 50MHz, however has not been tested on hardware until updated here. Very much still WIP, however 
  updates may be infrequent due to school and other commitments.

- Toast does not support interrupt handling, nor the CSR, FENCE, EBREAK, or ECALL instructions.

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





