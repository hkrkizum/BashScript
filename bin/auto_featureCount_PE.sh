#!/bin/bash

# mouse_annotation="/mnt/x/Bioinfomatics/Data/reference/Mouse/mouse_annotation.gtf"
mouse_annotation="/mnt/x/Bioinfomatics/Data/reference/Mouse_ref_genome_STAR/Mus_musculus.GRCm38.93.gtf"
rat_annotation="/mnt/x/Bioinfomatics/Data/reference/Rat_ref_genome_STAR/Rattus_norvegicus.Rnor_6.0.95.gtf"

while getopts i:o: OPT
do
  case $OPT in
    "i" ) FLG_A="TRUE" ; Iput_path="$OPTARG" ;;
  "o" ) FLG_B="TRUE" ; Output_path="$OPTARG" ;;
      * ) echo "Usage: $CMDNAME [-i VALUE] [-o VALUE] " 1>&2
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

for i in $(seq 1 ${Check_fileN1}); do
  echo "Readline:" $i
  # i行目を取得
  filepath=`head -n $i $Iput_path_ab | tail -n 1`
  tmp=`basename $filepath`
  foldername=${tmp:0:-4}
  #STAR実行
  featureCounts \
    -p \
    -T 8 \
    -t exon \
    -f \
    -s 0 \
    -O \
    -a $rat_annotation \
    -o ${foldername}_count.txt \
    $filepath

done

# echo "finished" | bash ~/Apps/notify-me.sh
echo "finished"

cd $CurrentDir