
RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32i

SHELL := /bin/bash
VERILATOR = verilator
IVERILOG = iverilog
VVP = vvp

TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin/riscv32-unknown-elf-
PATH:=$(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin:$(PATH)

WORKINGDIR = $(shell pwd)

TOAST_MODULES = $(shell ls $(WORKINGDIR)/rtl/*.{v,vh})

TOAST_TESTBENCH = $(WORKINGDIR)/testbench.v
RVTEST_MEMS = $(shell ls $(WORKINGDIR)/mem/hex/*.hex)



IVLG_FLAGS += -Wall



alltests: testbench.vvp 
	@echo "##############################################################"
	@echo "Running testbench.vvp with all riscv-tests. No VCD gen."
	$(VVP) -N $< $(RVTEST_MEMS) -I$(WORKINGDIR)/mem/hex +runall
	@echo ""
	@echo ""

alltests_vcd: testbench.vvp
	@echo "##############################################################"
	@echo "Running testbench.vvp with all riscv-tests and VCD gen."
	$(VVP) -N $< $(RVTEST_MEMS) -I$(WORKINGDIR)/mem/hex +runall +vcd
	@echo ""
	@echo ""


testbench.vvp: testmems
	@echo "##############################################################"
	@echo "Generating testbench.vvp"
	$(IVERILOG) $(IVLG_FLAGS) -o $@ $(TOAST_MODULES) $(TOAST_TESTBENCH)  \
	            -I$(WORKINGDIR)/rtl -I$(WORKINGDIR)/mem/hex
	@echo ""
	@echo ""

testmems: 
	@echo "##############################################################"
	@echo "Compiling, linking, and generating mem files for riscv-tests."
	@echo "Memory files will be placed into /mem/"
	@echo "Dump files will be placed into /mem/dump"
	chmod +x ./scripts/memgen.sh
	source ./scripts/memgen.sh
	@echo ""
	@echo ""

.PHONY: clean
clean:
	rm -rf testbench.vvp
	rm -rf testbench.vcd
	rm -r  mem

