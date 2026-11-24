#!/usr/bin/env python

# Step 3: assign cell types with CellTypist.
#
# Loads the combined count matrix produced by nf-core/scrnaseq (registered in
# LaminDB by nf-lamin), predicts immune cell types with CellTypist and saves
# the result as a new artifact.

import lamindb as ln
import scanpy as sc
import celltypist
from celltypist import models

ln.track()

# the combined count matrix registered by nf-lamin during the latest pipeline run
matrix = (
    ln.Artifact.filter(key__endswith="mtx_conversions/combined_cellbender_filter_matrix.h5ad")
    .order_by("-created_at")
    .first()
)
adata = matrix.load()

# celltypist expects log1p-normalised counts and gene symbols as var_names
adata.var_names = adata.var["gene_symbol"].astype(str)
adata.var_names_make_unique()
adata.var.index.name = None
sc.pp.normalize_total(adata, target_sum=1e4)
sc.pp.log1p(adata)

# predict immune cell types
models.download_models(model="Immune_All_Low.pkl")
predictions = celltypist.annotate(adata, model="Immune_All_Low.pkl", majority_voting=True)
adata.obs["cell_type"] = predictions.predicted_labels["majority_voting"].values
print(adata.obs["cell_type"].value_counts())

# save the cell typed matrix as a new artifact
output = ln.Artifact.from_anndata(
    adata,
    key="showcase/pbmc8k_celltyped.h5ad",
    description="10x PBMC 8k with CellTypist cell types (Immune_All_Low)",
).save()
print("Cell typed artifact uid:", output.uid)

ln.finish()
