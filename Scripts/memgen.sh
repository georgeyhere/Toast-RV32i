shopt -s extglob
#!/bin/bash

getfiles="ls $RVTEST_TESTDIR/*.S"  # list all .S files in directory
filenames=`$getfiles`              # store output of getfiles in filenames

echo "RVTEST_TESTDIR:"
echo $RVTEST_TESTDIR
echo "RVTEST_INCLUDE:"
echo $RVTEST_INCLUDE
echo $filenames

for eachfile in $filenames # run for each file in filenames
do
	if [ ! -f "$filenames" ] 
	then 
		riscv32-unknown-elf-gcc     -c $eachfile -I"$RVTEST_INCLUDE" -o "$eachfile.o"
		riscv32-unknown-elf-objdump -d $eachfile.o > $eachfile.dump
		riscv32-unknown-elf-elf2hex --bit-width 32 --input $eachfile.o > $eachfile.mem

	else
		echo "Warning: File \"$eachfile\" does not exist."
	fi
done

getMem="ls $RVTEST_TESTDIR/*.mem"
memnames=`$getMem`

for eachfile in $memnames
do
	mv $eachfile --target-directory=$RVPROJ_MEM
done