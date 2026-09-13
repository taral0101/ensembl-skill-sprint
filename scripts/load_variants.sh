#!/usr/bin/env bash
set -euo pipefail

# Bulk-load VCF variants into MySQL and report loading time.
#
# Usage:
#   ./scripts/load_variants.sh [input.vcf.gz] [output.tsv]
#
# Required environment variables:
#   MYSQL_USER
#   MYSQL_PASSWORD
#
# Optional environment variables:
#   MYSQL_HOST      (default: 127.0.0.1)
#   MYSQL_PORT      (default: 3306)
#   MYSQL_DATABASE  (default: vep)
#   MYSQL_TABLE     (default: variants)

INPUT_VCF="${1:-chr20.vcf.gz}"
OUTPUT_TSV="${2:-${INPUT_VCF%.vcf.gz}.tsv}"

MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_DATABASE="${MYSQL_DATABASE:-vep}"
MYSQL_TABLE="${MYSQL_TABLE:-variants}"

: "${MYSQL_USER:?Set MYSQL_USER before running this script}"
: "${MYSQL_PASSWORD:?Set MYSQL_PASSWORD before running this script}"

if [[ ! -f "$INPUT_VCF" ]]; then
    echo "ERROR: input VCF not found: $INPUT_VCF" >&2
    exit 1
fi

command -v bcftools >/dev/null 2>&1 || {
    echo "ERROR: bcftools is required but was not found in PATH" >&2
    exit 1
}

command -v mysql >/dev/null 2>&1 || {
    echo "ERROR: mysql client is required but was not found in PATH" >&2
    exit 1
}

echo "[1/2] Converting $INPUT_VCF to $OUTPUT_TSV"
bcftools query \
    -f '%CHROM\t%POS\t%ID\t%REF\t%ALT\t%QUAL\t%FILTER\t%INFO\n' \
    "$INPUT_VCF" > "$OUTPUT_TSV"

echo "[2/2] Loading variants into ${MYSQL_DATABASE}.${MYSQL_TABLE}"
{
    time MYSQL_PWD="$MYSQL_PASSWORD" mysql --local-infile=1 \
        -h"$MYSQL_HOST" \
        -P"$MYSQL_PORT" \
        -u"$MYSQL_USER" \
        "$MYSQL_DATABASE" \
        -e "LOAD DATA LOCAL INFILE '$(pwd)/$OUTPUT_TSV'
            INTO TABLE ${MYSQL_TABLE}
            FIELDS TERMINATED BY '\t'
            LINES TERMINATED BY '\n'
            (chrom, pos, id, ref, alt, qual, filter, info);"
} 2>&1

echo "Load completed successfully."
