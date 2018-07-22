#!/bin/bash

# Get parameters
while getopts i:o: OPT
do
  case $OPT in
    "i" ) FLG_A="TRUE" ; Iput_path="$OPTARG" ;;
    "o" ) FLG_B="TRUE" ; Output_path="$OPTARG" ;;
      * ) echo "Usage: $CMDNAME [-i VALUE] [-o VALUE] " 1>&2
          exit 1 ;;
  esac
done

# Make output, temp dir, and move
mkdir -p $Output_path/
cd $Output_path
mkdir -p temp/

# parallel gzip in input dir
find $Iput_path * | grep ^/.*.fastq$ > temp/fastq_list.dat
fastq_list=$(<temp/fastq_list.dat)
echo "gzip:" $fastq_list
for fastq_list_i in fastq_list; do
	pigz $fastq_list_i
done
echo "gzip complete"

# Get file list
find $Iput_path * | grep ^/.*_paired_output_1.fastq.gz$ > temp/fatq1_fo.dat
awk -v WD="$Iput_path" '{sub(WD, ""); print $0}' temp/fatq1_fo.dat > temp/fatq2_fo.dat
awk '{sub("_1.fastq.gz", ""); print $0}' temp/fatq2_fo.dat > temp/fatq3_fo.dat

find $Iput_path * | grep ^/.*_paired_output_2.fastq.gz$ > temp/fatq1_rv.dat
awk -v WD="$Iput_path" '{sub(WD, ""); print $0}' temp/fatq1_rv.dat > temp/fatq2_rv.dat
awk '{sub("_paired_output_1.fastq.gz", ""); print $0}' temp/fatq2_rv.dat > temp/fatq3_rv.dat


i=1
filelist=$(<temp/fatq1_fo.dat.dat)
for filepath in $filelist; do
	# リストのファイル名をループ回数に応じて取得、変数へ格納
	foldername=`cat temp/fatq3_fo.dat | awk -v num="$i" 'NR==num'`
	echo "Proceeding file is " $foldername

	foword=`cat temp/fatq1_fo.dat | awk -v num="$i" 'NR==num'`
	reverse=`cat temp/fatq1_rv.dat | awk -v num="$i" 'NR==num'`

	# gzファイルを展開
	unpigz $foword
	unpigz $reverse
	echo "gunzip complete" $filepath

	#展開したファイルを絶対PATHで取得し、変数へ格納
	Input_fastq_foword=`find ${Iput_path} * | grep ^/.*_paired_output_1.fastq$`
	Input_fastq_reverse=`find ${Iput_path} * | grep ^/.*_paired_output_2.fastq$`
	echo $Input_fastq_foword $Input_fastq_reverse
	#STAR実行
	STAR --genomeDir /mnt/x/Bioinfomatics/Data/reference/Mouse_ref_genome_STAR \
	--readFilesIn $Input_fastq \
	--runThreadN 6 \
 	--outSAMtype BAM SortedByCoordinate --outFileNamePrefix  $foldername \
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