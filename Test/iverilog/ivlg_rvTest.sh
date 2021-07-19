#!/bin/sh

iverilog -o toast_test -c toast_cmdFile.txt
vvp toast_test -fst