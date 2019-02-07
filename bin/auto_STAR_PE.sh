#!/bin/bash
while getopts f:r:o: OPT
do
  case $OPT in
    "f" ) FLG_A="TRUE" ; Iput_path_f="$OPTARG" ;;
	"r" ) FLG_B="TRUE" ; Iput_path_r="$OPTARG" ;;
    "o" ) FLG_C="TRUE" ; Output_path="$OPTARG" ;;
      * ) echo "Usage: $CMDNAME [-f VALUE] [-r VALUE] [-o VALUE] " 1>&2
          exit 1 ;;
  esac
done

CurrentDir=`pwd` # 現在のDir取得
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

# アウトプット先の作成
mkdir -p $Output_path/
cd $Output_path
echo $Output_path

for i in $(seq 1 ${Check_fileN1}); do
	echo "Readline:" $i
	# i行目を取得
	foword=`head -n $i $Iput_path_f_ab | tail -n 1`
	reverse=`head -n $i $Iput_path_r_ab | tail -n 1`

	# gzファイルを展開
	unpigz $foword
	unpigz $reverse
	echo "gunzip complete"

	# 共通名を取得
	foldername=`basename $foword | perl -pe 's/\.fastq\.gz//'`
	# 拡張子(.gz)を除いたファイル名(=解凍後のfastqファイル)名取得
	foword_name=`basename ${foword:0:-3}`
	reverse_name=`basename ${reverse:0:-3}`
	echo $foword_name
	echo $reverse_name

	#STAR実行
	STAR --genomeDir /mnt/x/Bioinfomatics/Data/reference/Rat_ref_genome_STAR \
	--readFilesIn ${foword:0:-3} ${reverse:0:-3} \
	--runThreadN 6 \
 	--outSAMtype BAM SortedByCoordinate --outFileNamePrefix  $foldername

	#展開した元fastqを再圧縮
	pigz ${foword:0:-3}
	pigz ${reverse:0:-3}
	echo "pigz complete, finesh"

done

echo "finished" | bash ~/Apps/notify-me.sh
echo "finished"

cd $CurrentDir

