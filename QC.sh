#!/bin/bash

# Input and output directories
Input="Input"
Output="Output"

# Create output directory if it doesn't exist
mkdir -p "$Output"

# Process each FASTQ file
for Fastq in "$Input"/*_R1.fastq.gz; do
    # Extract the base filename without the _R1.fastq.gz suffix
    filename1=$(basename "$Fastq" "_R1.fastq.gz")
    output_file="$Output/${filename1}_stats.txt"

    # Process the FASTQ file with awk
    awk '
    BEGIN {
        Total_Base = 0
        Totalreads = 0
        Qul20 = 0
        Qul30 = 0
        NumberofG = 0
        NumberofC = 0
        NumberofT = 0
        NumberofA = 0
        NumberofN = 0
    }
    NR % 4 == 2 {
        # Process sequence lines
        length_seq = length($0)
        Total_Base += length_seq
        Totalreads++
        for (i = 1; i <= length_seq; i++) {
            base = substr($0, i, 1)
            if (base == "G") NumberofG++
            else if (base == "C") NumberofC++
            else if (base == "T") NumberofT++
            else if (base == "A") NumberofA++
            else if (base == "N") NumberofN++
        }
    }
    NR % 4 == 0 {
        # Process quality lines
        for (i = 1; i <= length($0); i++) {
            quality = ord(substr($0, i, 1)) - 33
            if (quality >= 20) Qul20++
            if (quality >= 30) Qul30++
        }
    }
    END {
        # Print statistics
        printf "%-20s %s\n", "Filename:", "'"$filename1"'"
        printf "%-20s %d\n", "Total_Base:", Total_Base
        printf "%-20s %d\n", "Totalreads:", Totalreads
        printf "%-20s %d\n", "NumberofG:", NumberofG
        printf "%-20s %d\n", "NumberofA:", NumberofA
        printf "%-20s %d\n", "NumberofT:", NumberofT
        printf "%-20s %d\n", "NumberofC:", NumberofC
        printf "%-20s %d\n", "NumberofN:", NumberofN
        printf "%-20s %.2f%%\n", "%Qul20:", (Qul20 / Total_Base) * 100
        printf "%-20s %.2f%%\n", "%Qul30:", (Qul30 / Total_Base) * 100
    }
    # Function to get ASCII value of a character
    function ord(c) {
        return index(" !\"#$%&'\''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~", c) - 1
    }
    ' "$Fastq" > "$output_file"
done
