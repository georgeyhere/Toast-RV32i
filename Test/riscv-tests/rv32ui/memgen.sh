shopt -s extglob
#!/bin/bash

getfiles="$RVTEST_TESTDIR/*"

echo "RVTEST_TESTDIR:"
echo $RVTEST_TESTDIR

echo "RVTEST_INCLUDE:"
echo $RVTEST_INCLUDE

#filenames=`$getfiles`
#echo $filenames

for eachfile in $getfiles
do
	if [ ! -f "$filenames" ] 
	then 
		riscv32-unknown-elf-gcc     -c $eachfile -I"$RVTEST_INCLUDE"
		riscv32-unknown-elf-elf2hex --bit-width 32 --input $eachfile.o > $eachfile.mem 
		rm $eachfile.o
	else
		echo "Warning: File \"$eachfile\" does not exist."
	fi
done