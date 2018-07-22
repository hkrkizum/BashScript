#!/bin/bash
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

# parallel gzip in input dir
fastq_list=`find $Iput_path * | grep ^/.*.fastq$`
pigz $fastq_list
echo "gzip complete"

# Get file list
find $Iput_path * | grep ^/.*_1.fastq.gz$ > temp/fatq1_fo.dat
awk -v WD="$Iput_path" '{sub(WD, ""); print $0}' temp/fatq1_fo.dat > temp/fatq2_fo.dat
awk '{sub("_1.fastq.gz", ""); print $0}' temp/fatq2_fo.dat > temp/fatq3_fo.dat

find $Iput_path * | grep ^/.*_2.fastq.gz$ > temp/fatq1_rv.dat
awk -v WD="$Iput_path" '{sub(WD, ""); print $0}' temp/fatq1_rv.dat > temp/fatq2_rv.dat
awk '{sub(".fastq.gz", ""); print $0}' temp/fatq2_rv.dat > temp/fatq3_rv.dat


i=1
filelist_foword=$(<temp/fatq1_fo.dat)
filelist_reverse=$(<temp/fatq1_rv.dat)
for filepath in $filelist_foword; do
	# リストのファイル名をループ回数に応じて取得、変数へ格納
	foldername=`cat temp/fatq3_fo.dat | awk -v num="$i" 'NR==num'`

	foword=`cat temp/fatq1_fo.dat | awk -v num="$i" 'NR==num'`
	reverse=`cat temp/fatq1_rv.dat | awk -v num="$i" 'NR==num'`
	echo "Proceeding file is " $foldername

	# gzファイルを展開
	unpigz $foword
	unpigz $reverse
	echo "gunzip complete"

	#展開したファイルを絶対PATHで取得し、変数へ格納
	Input_fastq_foword=`find ${Iput_path} * | grep ^/.*_1.fastq$`
	Input_fastq_reverse=`find ${Iput_path} * | grep ^/.*_2.fastq$`
	echo "QC file is " $Input_fastq_foword $Input_fastq_reverse

	fastp \
	--in1 $Input_fastq_foword \
	--in2 $Input_fastq_reverse \
	--out1 ${foldername}_output_1.fastq \
	--out2 ${foldername}_output_2.fastq \
	--html ${foldername}.html \
	--json ${foldername}.json \
	--thread 8 \
	--qualified_quality_phred 30 \
	--trim_front1 15

	echo "trimmeing complete" $foldername
	echo "trimmeing complete" $foldername | bash ~/Apps/notify-me.sh

	#展開したfastqを再圧縮
	pigz *.fastq

	#展開したfastqを再圧縮
	pigz $Input_fastq_foword
	pigz $Input_fastq_reverse
	echo "pigz complete, finesh"
	
	let i++
done
rm -rf temp/

echo "Complete QC" | bash ~/Apps/notify-me.sh
exit 0