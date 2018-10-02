#!/bin/bash
source activate bioconda
CMDNAME=`basename $0`

while getopts i: OPT
do
  case $OPT in
    "i" ) FLG_A="TRUE" ; Iput_path="$OPTARG" ;;
      * ) echo "Usage: $CMDNAME [-i VALUE] " 1>&2
          exit 1 ;;
  esac
done

echo $Iput_path

# mkdir -p $Output_path/
# cd $Output_path
# mkdir temp/

# find $Iput_path * | grep ^/.*bam$ | perl -pe 's/\n/ /' > temp/fatq1.dat
# awk -v WD="$Iput_path" '{sub(WD, ""); print $0}' temp/fatq1.dat > temp/fatq2.dat
# awk '{sub(".bam", ""); print $0}' temp/fatq2.dat > temp/fatq3.dat

# i=1
# filelist=$(<temp/fatq1.dat)

# samtools merge -@ 8 merged.bam $filelist

# # rm -rf temp/
# echo "Complete merge" | bash ~/Apps/notify-me.sh