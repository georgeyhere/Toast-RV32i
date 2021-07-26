shopt -s extglob
#!/bin/bash

# This is a script to compile and link the assembly tests from riscv-tests and
# then generate a dump and memory configuration file for each test. 
#


WORKINGDIR=pwd
TESTDIR="`$WORKINGDIR`/test/riscv-tests/rv32ui/"
RVTEST_INCLUDE="`$WORKINGDIR`/test/riscv-tests/include/"


#############################################
# INSTRUCTIONS ARE ENCODED STARTING FROM 0X00000000
# DATA MEMORY IS ENCODED STARTING FROM 0X00002000

getfiles="ls $TESTDIR*.S"  
filenames=`$getfiles`             

for eachfile in $filenames 
do
	if [ ! -f "$filenames" ] 
	then 
		# compile and link using gcc and ld; then generate dump and $readmemh hexfile
		riscv32-unknown-elf-gcc     -c $eachfile -I"$RVTEST_INCLUDE" -o "$eachfile.o"
		riscv32-unknown-elf-ld      "$eachfile.o" -Ttext 0x00000000 -Tdata 0x00002000 -o $eachfile.v2
		riscv32-unknown-elf-objdump -d $eachfile.v2 > $eachfile.dump
		riscv32-unknown-elf-elf2hex --bit-width 32 --input $eachfile.v2 > $eachfile.hex
		rm $eachfile.v2
	else
		echo "Warning: File \"$eachfile\" does not exist."
	fi
done

#############################################
# move .mem files into /mem/hex, can be ommitted
getMem="ls $TESTDIR*.hex"
memnames=`$getMem`

if [ ! -d "`$WORKINGDIR`/mem/" ]
then
	echo "/mem/ does not exist, creating directory"
	mkdir mem	
fi

if [ ! -d "`$WORKINGDIR`/mem/hex/" ]
then
	echo "/mem/hex/ does not exist, creating directory"
	mkdir mem/hex/	
fi

echo "Moving memory files into /mem/hex/"
for eachfile in $memnames
do
	mv $eachfile --target-directory=`$WORKINGDIR`/mem/hex/
done

##################################################
# move dump files into /mem/dump, can be ommitted
getDump="ls $TESTDIR*.dump"
dumpnames=`$getDump`

if [ ! -d "`$WORKINGDIR`/mem/dump" ]
then
	echo "/Mem/dump does not exist, creating directory"
	mkdir `$WORKINGDIR`/mem/dump
fi

echo "Moving dump files into /mem/dump"
for eachfile in $dumpnames
do
	mv $eachfile --target-directory=`$WORKINGDIR`/mem/dump
done