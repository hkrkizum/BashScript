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

find $Iput_path * | grep ^/.*.fastq$ > temp/fastq_list.dat
fastq_list=$(<temp/fastq_list.dat)
echo "gzip:" $fastq_list
for fastq_list_i in fastq_list; do
	pigz $fastq_list_i
done
echo "gzip complete"

find $Iput_path -type f -name *.fastq.gz > temp/fatq1.dat
awk -v WD="$Iput_path" '{sub(WD, ""); print $0}' temp/fatq1.dat > temp/fatq2.dat
awk '{sub(".fastq.gz", ""); print $0}' temp/fatq2.dat > temp/fatq3.dat

folderlist=$(<temp/fatq3.dat)
for folder in $folderlist; do
	mkdir -p $Output_path$folder
done

i=1
filelist=$(<temp/fatq1.dat)
for filepath in $filelist; do
	# リストのファイル名をループ回数に応じて取得、変数へ格納
	foldername=`cat temp/fatq3.dat | awk -v num="$i" 'NR==num'`
	# echo "output folder is " $foldername | bash ~/Apps/notify-me.sh
	echo "output folder is " $foldername

	# #gzファイルを展開
	unpigz $filepath
	# echo "gunzip complete" $filepath | bash ~/Apps/notify-me.sh
	echo "gunzip complete" $filepath

	#展開したファイルを絶対PATHで取得し、変数へ格納
	Input_fastq=`find ${Iput_path} * | grep ^/.*.fastq$`
	echo $Input_fastq
	#STAR実行
	STAR --genomeDir /mnt/x/Bioinfomatics/Data/reference/Mouse_ref_genome_STAR \
	--readFilesIn $Input_fastq \
	--runThreadN 6 \
 	--outSAMtype BAM SortedByCoordinate --outFileNamePrefix  $foldername/$foldername \
 	--outFilterScoreMinOverLread 0 --outFilterMatchNminOverLread 0 --outFilterMismatchNmax 2
	echo "mapping complete" $Input_fastq | bash ~/Apps/notify-me.sh
	echo "mapping complete" $Input_fastq

 	#展開したfastqを再圧縮
	pigz $Input_fastq
 	# echo "gzip complete" $Input_fastq | bash ~/Apps/notify-me.sh
 	echo "gzip complete" $Input_fastq

 	#ループを回す
	let i++
done

# rm -rf temp

echo "finished" | bash ~/Apps/notify-me.sh
echo "finished" 

exit 0