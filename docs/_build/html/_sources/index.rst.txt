.. ToastCore documentation master file, created by
   sphinx-quickstart on Wed Jul 28 13:57:58 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Toast: A 32-bit RISC-V Core
=====================================

Toast is a 32-bit RISC-V core written in Verilog that implements a subset of the RV32I ISA version 2.2.

Toast supports all instructions from the RV32i base integer ISA with the exception of CSR, FENCE, EBREAK, and ECALL. Toast also does not support interrupt handling, although these features may be added in the future.

Toast has been tested using the official RV32ui unit tests from the riscv-tests repo but has not been formally verified. 


.. toctree::
    :maxdepth: 2
    :caption: Contents

    pipeline_details
    instruction_fetch
    instruction_decode
    execute
    mem