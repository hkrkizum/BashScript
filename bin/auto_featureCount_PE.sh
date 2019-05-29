#!/bin/bash

while getopts a:i:o: OPT
do
  case $OPT in
    "a" ) FLG_A="TRUE" ; Anotate_path="$OPTARG" ;;
    "i" ) FLG_B="TRUE" ; Iput_path="$OPTARG" ;;
    "o" ) FLG_C="TRUE" ; Output_path="$OPTARG" ;;
      * ) echo "Usage: $CMDNAME [-a VALUE] [-i VALUE] [-o VALUE] " 1>&2
          exit 1 ;;
  esac
done

CurrentDir=`pwd` # 現在のDir取得
Iput_path_ab=`realpath $Iput_path`
Check_fileN1=`cat $Iput_path_ab | wc -l`

# アウトプット先の作成
mkdir -p $Output_path/
cd $Output_path
echo $Output_path

tmp=`basename $Iput_path`
#STAR実行
featureCounts \
  -p \
  -T 8 \
  -t exon \
  -g gene_id \
  -s 0 \
  -O \
  -a $Anotate_path \
  -o ${tmp}_count.txt \
  `cat $Iput_path_ab`

# echo "finished" | bash ~/Apps/notify-me.sh
echo "finished"

cd $CurrentDir