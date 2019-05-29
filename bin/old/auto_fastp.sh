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
find $Iput_path * | grep ^/.*.fastq.gz$ > temp/fatq1.dat
awk -v WD="$Iput_path" '{sub(WD, ""); print $0}' temp/fatq1.dat > temp/fatq2.dat
awk '{sub(".fastq.gz", ""); print $0}' temp/fatq2.dat > temp/fatq3.dat

i=1
filelist=$(<temp/fatq1.dat)
for filepath in $filelist; do
	# リストのファイル名をループ回数に応じて取得、変数へ格納
	foldername=`cat temp/fatq3.dat | awk -v num="$i" 'NR==num'`
	echo "Proceeding file is " $foldername

	# # gzファイルを展開
	# unpigz $filepath
	# echo "gunzip complete"

	# #展開したファイルを絶対PATHで取得し、変数へ格納
	# Input_fastq=`find ${Iput_path} * | grep ^/.*.fastq$`
	# echo "QC file is " $Input_fastq

	fastp \
	--in1 $filepath \
	--out1 ${foldername}_output.fastq.gz \
	--html ${foldername}.html \
	--json ${foldername}.json \
	--thread 8 \
	--qualified_quality_phred 30

	echo "trimmeing complete" $foldername
	echo "trimmeing complete" $foldername | bash ~/Apps/notify-me.sh

	#展開したfastqを再圧縮
	# pigz $Input_fastq
	# echo "pigz complete, finesh"

	let i++
done
rm -rf temp/

echo "Complete QC" | bash ~/Apps/notify-me.sh
exit 0