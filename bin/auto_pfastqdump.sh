#!/bin/bash
while getopts i:p:o: OPT
do
  case $OPT in
    "i" ) FLG_A="TRUE" ; Iput_path="$OPTARG" ;;
	"p" ) FLG_B="TRUE" ; param_PE="$OPTARG" ;;
    "o" ) FLG_C="TRUE" ; Output_path="$OPTARG" ;;
      * ) echo "Usage: $CMDNAME [-i VALUE] [-p VALUE] [-o VALUE] " 1>&2
          exit 1 ;;
  esac
done

CurrentDir=`pwd` # 現在のDir取得
Iput_path_ab=`realpath $Iput_path`

# Inputのファイル数チェック
Check_fileN1=`cat $Iput_path_ab | wc -l`

# アウトプット先の作成
mkdir -p $Output_path/
cd $Output_path
echo $Output_path

for i in $(seq 1 ${Check_fileN1}); do
	echo "Readline:" $i
	# i行目を取得
	filepath=`head -n $i $Iput_path_ab | tail -n 1`
	echo $filepath

	# 共通名を取得
	filename=`basename $filepath | perl -pe 's/\.sra//'`
	echo $filename

	if [ "$param_PE"=1 ]; then
		pfastq-dump --threads 8 --split-files --outdir $Output_path $filepath
	# else if [ "param_PE"=0 ]; then
	# 	pfastq-dump --threads 8 --outdir $Output_path $filepath
	else
		echo "ERROR"
	fi

	pigz *.fastq
done

cd $CurrentDir

