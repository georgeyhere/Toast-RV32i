#!/bin/sh
echo "Adding Test Source Directory to PATH."
export PATH=~/Documents/work/RISCV/Toast-RV32i/Test:$PATH

echo "Setting Vivado xsim directory to TEST_DIR"
export TEST_DIR=~/Documents/work/RISCV/RISCV_Project/RISCV_Project.sim/sim_1/behav/xsim

echo "Opening dump.vcd in GTKWave."
gtkwave $TEST_DIR/dump.vcd


