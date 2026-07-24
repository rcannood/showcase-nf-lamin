#!/bin/bash

# Step 2: run nf-core/scrnaseq, consuming the samplesheet from LaminDB by uid.
# nf-lamin records the run, its inputs (samplesheet, FASTQs, reference) and the
# output count matrices in laminlabs/lamindata during execution.
set -euo pipefail

export NXF_VER=25.10.5
export NXF_SYNTAX_PARSER=v1
export AWS_PROFILE=lam

INPUT="lamin://laminlabs/lamindata/artifact/rF7oiknTdhpfqU5H"
OUTDIR="${LAMIN_TEST_BUCKET}/scrnaseq_showcase/run_$(date +%Y%m%d_%H%M%S)"

# Human GRCh38 reference (Ensembl release 110)
FASTA="https://ftp.ensembl.org/pub/release-110/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"
GTF="https://ftp.ensembl.org/pub/release-110/gtf/homo_sapiens/Homo_sapiens.GRCh38.110.gtf.gz"

nextflow run nf-core/scrnaseq \
  -r 4.1.0 \
  -profile docker \
  -c nextflow.config \
  -resume \
  --input "$INPUT" \
  --fasta "$FASTA" \
  --gtf "$GTF" \
  --protocol 10XV2 \
  --outdir "$OUTDIR"
