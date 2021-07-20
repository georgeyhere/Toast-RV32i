shopt -s extglob
#!/bin/bash

# This is a script to compile and link the assembly tests from riscv-tests and
# then generate a dump and memory configuration file for each test. 
#
# INSTRUCTIONS ARE ENCODED STARTING FROM 0X00000000
# DATA MEMORY IS ENCODED STARTING FROM 0X00002000

getfiles="ls $RVTEST_TESTDIR/*.S"  # list all .S files in directory
filenames=`$getfiles`              # store output of getfiles in filenames

echo "RVTEST_TESTDIR:"
echo $RVTEST_TESTDIR
echo "RVTEST_INCLUDE:"
echo $RVTEST_INCLUDE
echo $filenames

for eachfile in $filenames 
do
	if [ ! -f "$filenames" ] 
	then 
		# compile and link using gcc and ld; then generate dump and $readmemh hexfile
		riscv32-unknown-elf-gcc     -c $eachfile -I"$RVTEST_INCLUDE" -o "$eachfile.o"
		riscv32-unknown-elf-ld      "$eachfile.o" -Ttext 0x00000000 -Tdata 0x00002000 -o $eachfile.v2
		riscv32-unknown-elf-objdump -d $eachfile.v2 > $eachfile.dump
		riscv32-unknown-elf-elf2hex --bit-width 32 --input $eachfile.v2 > $eachfile.mem

	else
		echo "Warning: File \"$eachfile\" does not exist."
	fi
done

# move .mem files into /Mem, can be ommitted
getMem="ls $RVTEST_TESTDIR/*.mem"
memnames=`$getMem`

for eachfile in $memnames
do
	mv $eachfile --target-directory=$RVPROJ_MEM
done