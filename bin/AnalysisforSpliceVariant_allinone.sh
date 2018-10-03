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

# Merge Bam -------------------------------------------------------------------------
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
samtools sort -@ 8 -o merged.sort.bam merged.bam
echo "Complete sorting"

rm merged.bam
rm -rf temp/

# AddOrReplaceReadGroups -------------------------------------------------------------------------
echo "AddOrReplaceReadGroups start"
java -jar /home/hikaru/Apps/picard/build/libs/picard.jar AddOrReplaceReadGroups \
 	I=merged.sort.bam \
 	O=merged.sort.RG.bam \
 	SO=coordinate \
 	RGID=Test RGLB=TruSeq_RNA_stranded RGPL=illumina RGPU=HiSeq2000 RGSM=Test

rm merged.sort.bam

echo "AddOrReplaceReadGroups Complete"
echo "AddOrReplaceReadGroups Complete" | bash ~/Apps/notify-me.sh

# MarkDuplicates ----------------------------------------------------------------------------------
echo "MarkDuplicates start"

java -jar /home/hikaru/Apps/picard/build/libs/picard.jar MarkDuplicates \
 	I=merged.sort.RG.bam \
 	O=merged.sort.RG.MD.bam \
 	CREATE_INDEX=true \
 	VALIDATION_STRINGENCY=SILENT \
 	M=merged.sort.RG.MD.metrics

rm merged.sort.RG.bam

echo "MarkDuplicates Complete"
echo "MarkDuplicates Complete" | bash ~/Apps/notify-me.sh

# MarkDuplicates ----------------------------------------------------------------------------------
echo "SplitNCigarReads start"

gatk SplitNCigarReads \
 -R $DataDir/genome.fa \
 -I merged.sort.RG.MD.bam \
 -O merged.sort.RG.MD.SplitN.bam

rm merged.sort.RG.MD.bam

echo "SplitNCigarReads Complete"
echo "SplitNCigarReads Complete" | bash ~/Apps/notify-me.sh

# Detection of variations by GATK HaplotypeCaller -----------------------------------------------------
echo "HaplotypeCaller start"

gatk HaplotypeCaller -R /mnt/x/Bioinfomatics/Data/reference/Mouse_ref_genome_STAR/Mus_musculus.GRCm38.dna.primary_assembly.fa \
 -I merged.sort.RG.MD.SplitN.bam \
 -stand-call-conf 20 --dont-use-soft-clipped-bases \
 -O variation.vcf.gz

echo "HaplotypeCaller Complete"
echo "HaplotypeCaller Complete" | bash ~/Apps/notify-me.sh

echo "VariantFiltration start"

gatk VariantFiltration -R /mnt/x/Bioinfomatics/Data/reference/Mouse_ref_genome_STAR/Mus_musculus.GRCm38.dna.primary_assembly.fa \
 -V variation.vcf.gz \
 -window 20 -cluster 3 \
 --filter-name "QD" --filter "QD < 2.0" \
 --filter-name "FS" --filter "FS > 60.0" \
 -O variation.filter.vcf.gz

echo "VariantFiltration Complete"
echo "VariantFiltration Complete" | bash ~/Apps/notify-me.sh
