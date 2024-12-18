import vcf
import csv

# Open the VCF file
vcf_file = 'Example_vcf_file.vcf' 

My_data = []

with open(vcf_file, 'r') as vcf_handle:
    reader = vcf.Reader(vcf_handle)

    for record in reader:
        
        chromosome = record.CHROM
        position = record.POS
        ref = record.REF
        alt = [str(alt) for alt in record.ALT]  
        quality = record.QUAL
        depth = record.INFO.get('DP')  
        allele_cov = record.INFO.get('AO') 
        frequency = record.INFO.get('AF')  

       
        sample = record.samples[0]  
        genotype = sample['GT']  

        if genotype == '0/0':
            genotype_class = 'Homozygous Reference'
        elif genotype == '1/1':
            genotype_class = 'Homozygous Alternate'
        elif genotype == '0/1' or genotype == '1/0':
            genotype_class = 'Heterozygous'
        else:
            genotype_class = 'Unknown'

        My_data.append({
            "Chromosome": chromosome,
            "Position": position,
            "Ref": ref,
            "Alt": alt,
            "Call": genotype_class,
            "Frequency": frequency,
            "Quality": quality,
            "Depth": depth,
            "Allele Coverage": allele_cov
        })

csv_file = 'My_data.csv'  
with open(csv_file, 'w', newline='') as csvfile:
    fieldnames = ["Chromosome", "Position", "Ref", "Alt", "Call", "Frequency", "Quality", "Depth", "Allele Coverage"]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()  
    for data in My_data:
        writer.writerow(data)  

print(f"Data has been successfully written to {csv_file}.")
