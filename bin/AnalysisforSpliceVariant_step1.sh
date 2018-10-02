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
mkdir temp/

echo "Bam merge script"
echo "Bam list:\n" `find $Iput_path * | grep ^/.*bam$`

find $Iput_path * | grep ^/.*bam$ | perl -pe 's/\n/ /' > temp/fatq1.dat
awk -v WD="$Iput_path" '{sub(WD, ""); print $0}' temp/fatq1.dat > temp/fatq2.dat
awk '{sub(".bam", ""); print $0}' temp/fatq2.dat > temp/fatq3.dat


filelist=$(<temp/fatq1.dat)
echo "Bam merge start"
samtools merge -@ 8 merged.bam $filelist
echo "Complete merge"
echo "Complete merge" | bash ~/Apps/notify-me.sh

echo "Bam sorting start"
samtools sort -@ 8 merged.bam
echo "Complete sorting"

rm -rf temp/
echo "Complete all job" | bash ~/Apps/notify-me.sh