#!/bin/bash

# Set param ------------------------------------------------
export FILENAME=$(basename $0)
CurrentDir=`pwd` # 現在のDir取得
FLG_A=0
FLG_B=0
FLG_C=0
FLG_D=0

# Get arg --------------------------------------------------
while getopts g:f:r:o:h OPT
do
  case $OPT in
  	"g" ) FLG_A=1 ; Genome_path="$OPTARG" ;;
    "f" ) FLG_B=1 ; Iput_path_f="$OPTARG" ;;
	"r" ) FLG_C=1 ; Iput_path_r="$OPTARG" ;;
    "o" ) FLG_D=1 ; Output_path="$OPTARG" ;;
	"h" ) echo "Usage: ${FILENAME} -g /path/to/genome/index/ -f /path/to/foward_read_list -r /path/to/reverse_read_list -o /path/to/outdir"
	      exit 1 ;;
      * ) echo "Usage: $CMDNAME [-g VALUE] [-f VALUE] [-r VALUE] [-o VALUE] " 1>&2
          exit 1 ;;
  esac
done

if [[ $FLG_A -eq 1 ]] && [[ $FLG_B -eq 1 ]] && [[ $FLG_C -eq 1 ]] && [[ $FLG_D -eq 1 ]];then
	echo "option command validated"
else
	echo "wrong option number"
	exit 1
fi

# validate files --------------------------------------------------
if [[ ! -d $Genome_path ]]; then
	echo "no Index dir"
	exit 1
fi

if [[ ! -e $Iput_path_f ]]; then
	echo "no list_f file"
	exit 1
fi

if [[ ! -e $Iput_path_r ]]; then
	echo "no list_r file"
	exit 1
fi

mkdir -p $Output_path/
if [[ ! -d $Output_path ]]; then
	echo "no output dir"
	exit 1
fi

# validate fastq.gz ------------------------------------------------
Iput_path_f_ab=`realpath $Iput_path_f`
Iput_path_r_ab=`realpath $Iput_path_r`

# Inputのファイル数チェック
Check_fileN1=`cat $Iput_path_f_ab | wc -l`
Check_fileN2=`cat $Iput_path_r_ab | wc -l`
if [ $Check_fileN1 = $Check_fileN2 ]; then
	echo "File number is same"  $Check_fileN1 $Check_fileN2
else
	echo "File number is not same:" $Check_fileN1 $Check_fileN2
fi

for i in $(seq 1 ${Check_fileN1}); do
	echo "---------------------------------------------------------"
	echo "Readline:" $i
	# get row i file name
	foword=`head -n $i $Iput_path_f_ab | tail -n 1`
	reverse=`head -n $i $Iput_path_r_ab | tail -n 1`

	# unpigz
	echo "gunzip start........"
	unpigz -p 6 $foword
	unpigz -p 6 $reverse
	echo "gunzip complete"

	# modifiy filename -- fastq.gz to fastq
	foword_name=`basename ${foword:0:-3}`
	reverse_name=`basename ${reverse:0:-3}`

	echo "Input fastq: " $foword_name " " $reverse_name

	# make output filename
	foldername=${Output_path}/`basename $foword | perl -pe 's/\.fastq\.gz//'`
	echo "Output file prefix: " $foldername

	# run STAR
	STAR \
	--genomeDir ${Genome_path} \
	--readFilesIn ${foword:0:-3} ${reverse:0:-3} \
	--runThreadN 6 \
 	--outSAMtype BAM SortedByCoordinate \
 	--outFileNamePrefix $foldername \
 	--outFilterMultimapNmax 1

	# compress fassq
	echo "fastq pigz start........"
	pigz -p 6 ${foword:0:-3}
	pigz -p 6 ${reverse:0:-3}
	echo "pigz complete, finesh"

done

echo "finished"
cd $CurrentDir