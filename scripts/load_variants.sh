#!/usr/bin/env bash
set -euo pipefail

#----------------------------------------------------------------
# Horizon1 Day 3: Bulk‐load chr20 into MySQL and benchmark
#----------------------------------------------------------------

# 1) Convert VCF → TSV using bcftools
#    Extracts CHROM, POS, ID, REF, ALT, QUAL, FILTER, INFO as tab-delimited
bcftools query \
  -f '%CHROM\t%POS\t%ID\t%REF\t%ALT\t%QUAL\t%FILTER\t%INFO\n' \
  chr20.vcf.gz > chr20.tsv

# 2) Load into MySQL and time the operation
#    Uses LOCAL INFILE for fastest ingestion
{ time mysql --local-infile=1 \
    -h127.0.0.1 -P3306 \
    -uroot -pmy_secret_pw vep \
    -e "LOAD DATA LOCAL INFILE '$(pwd)/chr20.tsv'
        INTO TABLE variants
        FIELDS TERMINATED BY '\t'
        LINES TERMINATED BY '\n'
        (chrom, pos, id, ref, alt, qual, filter, info);" ; } 2>&1
