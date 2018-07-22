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
find $Iput_path * | grep ^/.*.fastq$ > temp/fastq_list.dat
fastq_list=$(<temp/fastq_list.dat)
echo "gzip:" $fastq_list
for fastq_list_i in fastq_list; do
	pigz $fastq_list_i
done
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
	echo "gunzip complete" $filepath

	#展開したファイルを絶対PATHで取得し、変数へ格納
	Input_fastq_foword=`find ${Iput_path} * | grep ^/.*_1.fastq$`
	Input_fastq_reverse=`find ${Iput_path} * | grep ^/.*_2.fastq$`
	echo $Input_fastq_foword $Input_fastq_reverse

	java -jar /home/hikaru/Apps/Trimmomatic-0.38/trimmomatic-0.38.jar \
		PE \
	    -threads 8 \
	    -phred33 \
	    -trimlog ${foldername}_log.txt \
	    $Input_fastq_foword \
	    $Input_fastq_reverse \
	    ${foldername}_paired_output_1.fastq \
	    ${foldername}_unpaired_output_1.fastq \
	    ${foldername}_paired_output_2.fastq \
	    ${foldername}_unpaired_output_2.fastq \
	    ILLUMINACLIP:/home/hikaru/Apps/Trimmomatic-0.38/adapters/TruSeq3-PE.fa:2:30:10 \
	    SLIDINGWINDOW:4:15 \
	    LEADING:30 \
	    TRAILING:30 \
	    MINLEN:30
	echo "trimmeing complete" 
	echo "trimmeing complete" | bash ~/Apps/notify-me.sh

	#展開したfastqを再圧縮
	pigz $Input_fastq_foword
	pigz $Input_fastq_reverse
	echo "pigz complete, finesh"
	
	let i++
done
# rm -rf temp/
exit 0