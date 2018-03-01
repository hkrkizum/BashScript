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
mkdir -p temp/

find $Iput_path * | grep ^/.*.fastq.gz$ > temp/fatq1.dat
awk -v WD="$Iput_path" '{sub(WD, ""); print $0}' temp/fatq1.dat > temp/fatq2.dat
awk '{sub(".fastq.gz", ""); print $0}' temp/fatq2.dat > temp/fatq3.dat

folderlist=$(<temp/fatq3.dat)
for folder in $folderlist; do
	mkdir -p $Output_path$folder
done
wait

i=1
filelist=$(<temp/fatq1.dat)
for filepath in $filelist; do
	foldername=`cat temp/fatq3.dat | awk -v num="$i" 'NR==num'`
	echo "output folder is " $foldername
	echo $filepath
	java -jar trimmomatic-0.36.jar \
		SE \
	    -threads 8 \
	    -phred33 \
	    -trimlog log.txt \
	    $1 \
	    $2 \
	    ILLUMINACLIP:/mnt/c/Bioinfomatics/Apps/Trimmomatic/adapters/TruSeq3-SE.fa:2:30:10 \
	    MINLEN:30
	let i++
done

exit 0