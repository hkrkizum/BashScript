#!/bin/bash

CMDNAME=`basename $0`

while getopts i:o: OPT
do
  case $OPT in
    "i" ) FLG_A="TRUE" ; Iput_path="$OPTARG" ;;
    "o" ) FLG_B="TRUE" ; Output_path="$OPTARG" ;;
      * ) echo "Usage: $CMDNAME [-i VALUE] [-o VALUE] " 1>&2
          exit 1 ;;
  esac
done

mkdir -p $Output_path/
cd $Output_path
mkdir -p temp/

find $Iput_path * | grep ^/.*.sra$ > temp/fatq1.dat
awk -v WD="$Iput_path" '{sub(WD, ""); print $0}' temp/fatq1.dat > temp/fatq2.dat
awk '{sub(".sra", ""); print $0}' temp/fatq2.dat > temp/fatq3.dat

i=1
filelist=$(<temp/fatq1.dat)
for filepath in $filelist; do
	foldername=`cat temp/fatq3.dat | awk -v num="$i" 'NR==num'`
	echo "proceeding file is " $foldername
	parallel-fastq-dump --sra-id ${filepath} --threads 8 --outdir ${Output_path} --tmpdir /mnt/x/tmp/ --split-files
  	pigz -p 8 *.fastq
	let i++
done

rm -rf temp/

echo "finish fastq-dump" | bash ~/Apps/notify-me.sh
exit 0
