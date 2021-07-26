__/vivado__
- openVivado.sh -> launch vivado and gui

__memgen.sh__
- compile riscv-tests using riscv32-unknown-elf-gcc
- link using riscv32-unknown-elf-ld
- generate dumpfiles using riscv32-unknown-elf-objdump
- generate hex files for $readmemh using [riscv32-unknown-elf-elf2hex](https://github.com/sifive/elf2hex)

__openDump.sh__
- open vcd file from vivado project directory in gtkwave

__setTestEnv.sh__
- set shell environment variables (run before memgen.sh)