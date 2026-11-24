#!/usr/bin/env Rscript

# Step 1: build a samplesheet and register it in LaminDB.
#
# Data: nf-core/scrnaseq's full test dataset, 10x Chromium v2 scRNAseq of ~8k
# human PBMCs (2 lanes), hosted on the public s3://ngi-igenomes bucket. S3 paths
# stage reliably (unlike ENA's FTP over HTTPS) and nf-lamin tracks them as artifacts.

library(laminr)
ln <- import_module("lamindb")
ln$track("lImad5Q6qnIPcTAE", path = "1_samplesheet_pbmc8k.R")

# One sample ("pbmc8k"), sequenced over two lanes.
base <- "s3://ngi-igenomes/test-data/scrnaseq"
samplesheet <- data.frame(
  sample = "pbmc8k",
  fastq_1 = c( # R1 = barcode + UMI
    paste0(base, "/pbmc8k_S1_L007_R1_001.fastq.gz"),
    paste0(base, "/pbmc8k_S1_L008_R1_001.fastq.gz")
  ),
  fastq_2 = c( # R2 = cDNA
    paste0(base, "/pbmc8k_S1_L007_R2_001.fastq.gz"),
    paste0(base, "/pbmc8k_S1_L008_R2_001.fastq.gz")
  ),
  expected_cells = 10000
)
write.csv(samplesheet, "samplesheet.csv", row.names = FALSE)
print(samplesheet)

# Register the samplesheet as a LaminDB artifact; its uid becomes the pipeline input.
sheet <- ln$Artifact(
  "samplesheet.csv",
  key = "showcase/pbmc8k_samplesheet.csv",
  description = "nf-core/scrnaseq samplesheet for 10x PBMC 8k (human)"
)$save()

# step 2 reads the uid from this file
writeLines(sheet$uid, "samplesheet.uid")
cat("\nSamplesheet artifact uid:", sheet$uid, "\n")

ln$finish()
