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

gatk SplitNCigarReads \
 -R /mnt/x/Bioinfomatics/Data/reference/Mouse_ref_genome_STAR/Mus_musculus.GRCm38.dna.primary_assembly.fa \
 -I $Iput_path \
 -O Aligned.sortedByCoord.RG.MD.SplitN.out.bam

echo "Complete" $Iput_path
echo "Complete merge" | bash ~/Apps/notify-me.sh