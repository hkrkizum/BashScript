#!/bin/bash
source activate bioconda
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

echo "Proceeding file is" $Iput_path

java -jar /home/hikaru/Apps/picard/build/libs/picard.jar AddOrReplaceReadGroups \
 	I=$Iput_path \
 	O=merged.sort.RG.bam \
 	SO=coordinate \
 	RGID=Test RGLB=TruSeq_RNA_stranded RGPL=illumina RGPU=HiSeq2000 RGSM=Test

echo "Complete" $Iput_path
echo "Complete merge" | bash ~/Apps/notify-me.sh