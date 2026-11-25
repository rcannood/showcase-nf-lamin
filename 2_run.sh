#!/bin/bash

# Step 2: run nf-core/scrnaseq on the samplesheet registered in step 1.
# nf-lamin records the run, its inputs (samplesheet, FASTQs, reference) and the
# output count matrices in LaminDB during execution.
set -euo pipefail

# settings, see the README
: "${LAMIN_API_KEY:?should be set to your Lamin API key}"
: "${LAMIN_CURRENT_INSTANCE:?should be set to your instance, e.g. my-org/my-instance}"
: "${OUTDIR:?should be set to where the outputs are published, e.g. s3://my-bucket/showcase/scrnaseq_pbmc8k or lamin://my-org/my-instance#prefix=showcase/scrnaseq_pbmc8k}"

export NXF_VER=25.10.5
export NXF_SYNTAX_PARSER=v1

# the samplesheet registered in step 1, referenced by its uid
INPUT="lamin://${LAMIN_CURRENT_INSTANCE}/artifact/$(cat samplesheet.uid)"

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
