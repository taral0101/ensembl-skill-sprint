# Ensembl Skill Sprint

A small, reproducible bioinformatics project demonstrating practical work with **Ensembl VEP**, custom plugin development, automated testing, variant transformation, and **MySQL** bulk loading.

The repository was developed as a skills sprint to practise components that are relevant to production genomics workflows: extending annotation behaviour, validating code with tests, handling VCF-derived data, and loading large variant tables efficiently into a relational database.

## What is included

- `plugins/ClinVarFlag.pm` — custom Perl plugin for Ensembl VEP that adds a flag when the input annotation contains a pathogenic ClinVar significance.
- `t/clinvarflag.t` — automated unit tests for the custom plugin using `Test::More`.
- `scripts/load_variants.sh` — Bash utility that converts a compressed VCF to TSV with `bcftools` and bulk-loads the result into MySQL using `LOAD DATA LOCAL INFILE`.
- `tests/test.vcf` — small test VCF used as a lightweight fixture.
- `docs/` — supporting documentation/figures from the sprint.

## Technologies

- Ensembl VEP 114
- Perl
- Bash
- bcftools
- MySQL
- Git/GitHub
- Linux/UNIX

## Repository structure

```text
.
├── docs/
├── plugins/
│   └── ClinVarFlag.pm
├── scripts/
│   └── load_variants.sh
├── t/
│   └── clinvarflag.t
└── tests/
    └── test.vcf
```

## Running the plugin tests

From the repository root:

```bash
prove -v t/clinvarflag.t
```

The tests exercise expected plugin behaviour for pathogenic and non-pathogenic ClinVar significance values.

## Variant loading utility

The loader accepts an input VCF and optional output TSV:

```bash
./scripts/load_variants.sh input.vcf.gz output.tsv
```

### Required environment variables

```bash
export MYSQL_USER="your_user"
export MYSQL_PASSWORD="your_password"
```

### Optional environment variables

```bash
export MYSQL_HOST="127.0.0.1"
export MYSQL_PORT="3306"
export MYSQL_DATABASE="vep"
export MYSQL_TABLE="variants"
```

The script checks for its input file and required command-line tools before execution, converts the VCF to tabular form with `bcftools query`, and then performs a timed MySQL bulk load.

> Credentials are intentionally supplied at runtime and are not stored in the repository.

## Quality and validation

The project uses small, inspectable fixtures and automated tests to make behaviour reproducible and easier to review. Changes to annotation logic are checked against expected outputs before being incorporated. The loading script also uses strict Bash error handling (`set -euo pipefail`) and validates required dependencies and configuration before execution.

## Context

This repository is a focused skills project rather than a complete production annotation service. Its purpose is to demonstrate how I approach bioinformatics engineering tasks: make assumptions explicit, automate repetitive steps, test biological logic, keep configuration separate from code, and document how the workflow is expected to behave.

## Author

**Taral Patel**  
Bioinformatics Engineer  
GitHub: [taral0101](https://github.com/taral0101)
