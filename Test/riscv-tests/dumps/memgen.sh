shopt -s extglob



getfiles="ls rv32ui!(*.dump|*.hex)"

filenames=`$getfiles`

workingdir="Documents/work/RISCV/Toast-RV32i/Test/riscv-tests/dumps/rv32ui"

echo $workingdir

echo $filenames

for eachfile in $filenames
do
	if [ ! -f "$filenames" ] 
	then 
		riscv32-unknown-elf-ld "$workingdir"/$eachfile -Ttext 0x00000000 -Tdata 0x00002000 -o $eachfile.v2
		riscv32-unknown-elf-elf2hex --bit-width 32 --input $eachfile.v2 > $eachfile.mem 
		rm $eachfile.v2
	else
		echo "Warning: File \"$eachfile\" does not exist."
	fi
done