# ! /bin /bash

# downlode the data

#wget -P /GATK/reads ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR062/SRR062635/SRR062635_1.fastq.gz

#wget -P ~/GATK/reads ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR062/SRR062635/SRR062635_2.fastq.gz

# download reference files##

#wget -P /home/laxmitulasi/GATK/supporting_files/hg38 https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz

#gunzip  /home/laxmitulasi/GATK/supporting_files/hg38/hg38.fa.gz

#index ref file before running haplotype caller 

#samtools faidx supporting_files/hg38/hg38.fa

# ref dict - .dict before running haplotype caller

#gatk CreateSequenceDictionary \
 -R supporting_files/hg38/hg38.fa \
 -O supporting_files/hg38/hg38.dict


# Downlode known sites files from GATK resource bundle 

#wget  -P supporting_files/hg38/  https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf

#wget -P supporting_files/hg38/  https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.idx


##### Variant calling ######

# directories
ref="supporting_files/hg38/hg38.fa"
known_sits="GATK/supporting_files/hg38/Homo_sapiens_assembly38.dbsnp138.vcf"
alignment_reads="aligned_reads/"
reads="reads"
results="results"
data="data"

#extract SNPS & INDELS

#gatk SelectVariants -R ${ref} -V ${results}/Raw_varients.vcf --select-type SNP -O ${results}/Raw_varients_SNP.vcf

#gatk SelectVariants -R ${ref} -V ${results}/Raw_varients.vcf --select-type INDEL -O ${results}/Raw_varients_INDEL.vcf

# -------------------
# Filter Variants - GATK4
# -------------------


# Filter SNPs
#gatk VariantFiltration \
	-R ${ref} \
	-V ${results}/Raw_varients_SNP.vcf \
	-O ${results}/filtered_snps.vcf \
	-filter-name "QD_filter" -filter "QD < 2.0" \
	-filter-name "FS_filter" -filter "FS > 60.0" \
	-filter-name "MQ_filter" -filter "MQ < 40.0" \
	-filter-name "SOR_filter" -filter "SOR > 4.0" \
	-filter-name "MQRankSum_filter" -filter "MQRankSum < -12.5" \
	-filter-name "ReadPosRankSum_filter" -filter "ReadPosRankSum < -8.0" \
	-genotype-filter-expression "DP < 10" \
	-genotype-filter-name "DP_filter" \
	-genotype-filter-expression "GQ < 10" \
	-genotype-filter-name "GQ_filter"



# Filter INDELS
#gatk VariantFiltration \
	-R ${ref} \
	-V ${results}/Raw_varients_INDEL.vcf \
	-O ${results}/filtered_indels.vcf \
	-filter-name "QD_filter" -filter "QD < 2.0" \
	-filter-name "FS_filter" -filter "FS > 200.0" \
	-filter-name "SOR_filter" -filter "SOR > 10.0" \
	-genotype-filter-expression "DP < 10" \
	-genotype-filter-name "DP_filter" \
	-genotype-filter-expression "GQ < 10" \
	-genotype-filter-name "GQ_filter"


# Select Variants that PASS filters
gatk SelectVariants \
	--exclude-filtered \
	-V ${results}/filtered_snps.vcf \
	-O ${results}/analysis-ready-snps.vcf


gatk SelectVariants \
	--exclude-filtered \
	-V ${results}/filtered_indels.vcf \
	-O ${results}/analysis-ready-indels.vcf























