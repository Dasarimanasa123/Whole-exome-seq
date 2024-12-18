#!/Bin/Bash

echo "Run prep files..."

### prep files ( generated only once)#################

## downlode the reference file####

# wget -p /home/manasa/BAM Files/wes/references/ https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz

#gunzip /references/hg38.fa.gz

# index reference file - .fai file for haplotype caller

#samtools faidx references/HG38/hg38.fa

# ref dict  - .dict file before running haplotype caller

#gatk CreateSequenceDictionary -R references/HG38/hg38.fa -O references/HG38/hg38.dict

## download known sites files for BQSR from GATK Resource bundle

#wget -p references/HG38/ https://console.cloud.google.com/storage/browser/gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.gz
#wget -p references/HG38/ https://console.cloud.google.com/storage/browser/gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.idx

###### Varient calling Steps ######

# directores ##

ref="references/HG38/hg38.fa"
Known_sites="references/HG38/hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf"
aligned_reads="align_reads/"
reads="reads"
results="results"
data="data"

#------
# step 1 : QC - Run fastqc 
#------

echo "STEP 1 :QC - RUN FASTQC"

#fastqc $reads/40504702795-Mr-HARNITTAN-SINGH_S22_L001_R1_001.fastq.gz -0 ${reads}/
#fastqc $reads/40504702795-Mr-HARNITTAN-SINGH_S22_L001_R2_001.fastq.gz -0 ${reads}/

#-----
#no trimming 

#------
# step 2 : map to reference using BWA-MEM 
#-----

echo "step 2 : map to reserence using BWA-MEM"

# BWA Index reference

#bwa index ${ref}

# bma alignment

#bwa mem -t 4 -R "@RG\tID:XXX\tLB:XXX\tPL:ILLUMINA\tPM:NOVOSEQ\tSM:XXX" ${ref} ${reads}/40504702795-Mr-HARNITTAN-SINGH_S22_L001_R1_001.fastq.gz ${reads}/40504702795-Mr-HARNITTAN-SINGH_S22_L001_R2_001.fastq.gz > ${aligned_reads}/HARNITTAN.sam

## step :3 Mark Duplicates and sort - GATK

echo "STEP 3 : Mark Duplicates and sort - GATK"

#samtools view -S -b ${aligned_reads}/HARNITTAN.sam > ${aligned_reads}/HARNITTAN.bam

# Sort the BAM file
#samtools sort -o ${aligned_reads}/sorted_HARNITTAN.bam ${aligned_reads}/HARNITTAN.bam

# Index the BAM file (optional)

#samtools index ${aligned_reads}/sorted_HARNITTAN.bam

#picard SortSam I=${aligned_reads}/HARNITTAN.bam O=${aligned_reads}/sorted_HARNITTAN_1.bam SORT_ORDER=coordinate


#gatk MarkDuplicates -I ${aligned_reads}/sorted_HARNITTAN_1.bam -O ${aligned_reads}/HARNITTAN_Sorted_dedup_reads.bam -M ${aligned_reads}/metrics.txt



#gatk MarkDuplicatesSpark -I ${aligned_reads}/HARNITTAN.sam --output ${aligned_reads}/HARNITTAN_Sorted_dedup_reads.bam -M duplication_metrics.txt

#-----------------------------
#STEP 4 : Base quality recalibration
#-----------------------------

echo "step 4 : base quality recalibration"

# 1.. build the model

#gatk BaseRecalibrator -I ${aligned_reads}/HARNITTAN_Sorted_dedup_reads.bam -R ${ref} --known-sites ${Known_sites} -O ${data}/recal_data.table

#  apply the model to adjust the base quality score

#gatk ApplyBQSR -I ${aligned_reads}/HARNITTAN_Sorted_dedup_reads.bam -R ${ref} --bqsr-recal-file ${data}/recal_data.table -O ${aligned_reads}/HARNITTAN_Sorted_dedup_reads_bqsr.bam

#-----------------------------
#STEEP 5 : Collect Alignment & insert size 
# ---------------------------

echo "step 5 : Collect Alignment & insert size"

#gatk CollectAlignmentSummaryMetrics -R ${ref} -I ${aligned_reads}/HARNITTAN_Sorted_dedup_reads_bqsr.bam -O ${aligned_reads}/Alignment_metricx.txt
#gatk CollectInsertSizeMetrics -I ${aligned_reads}/HARNITTAN_Sorted_dedup_reads_bqsr.bam -O ${aligned_reads}/insert_size_metrics.txt -H ${aligned_reads}/insert_size_histogram.pdf

##----------------------------------
# step 6 : call varients - gatk halotype caller 
##------------------------------------

echo "step 6 : call varients - gatk halotype caller"

gatk HaplotypeCaller -R ${ref} -I ${aligned_reads}/HARNITTAN_Sorted_dedup_reads_bqsr.bam  -O ${results}/Raw_varients.vcf











