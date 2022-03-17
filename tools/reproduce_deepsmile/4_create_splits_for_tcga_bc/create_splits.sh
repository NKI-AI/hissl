#!/bin/bash

# Usage: ~/hissl/tools/reproduce_deepsmile/4_create_splits_for_tcga_bc: bash create_splits.sh

SINGULARITYIMAGE=../../../hissl_deepsmile.sif

singularity exec --no-home \
      --bind ../../../../hissl:/hissl \
      --pwd /hissl/tools/reproduce_deepsmile/4_create_splits_for_tcga_bc \
      $SINGULARITYIMAGE \
      python create_splits_tcga_bc.py

#Concatenate paths for train and val per fold for SSL pretraining on both train and val.
FOLDS=(0 1 2 3 4)
for FOLD in "${FOLDS[@]}"
do
    touch "splits/paths_trainval_fold-${FOLD}_subset-1.0.txt"
    {
     cat "splits/paths_wsi_tcga_bc_set-train_fold-${FOLD}.txt"
     cat "splits/paths_wsi_tcga_bc_set-val_fold-${FOLD}.txt"
    } >> "splits/paths_trainval_fold-${FOLD}_subset-1.0.txt"
done

touch "splits/paths_all.txt"
{
 cat "splits/paths_wsi_tcga_bc_set-train_fold-0.txt"
 cat "splits/paths_wsi_tcga_bc_set-test_fold-0.txt"
 cat "splits/paths_wsi_tcga_bc_set-val_fold-0.txt"
} >> "splits/paths_all.txt"

singularity exec --no-home \
      --bind ../../../../hissl:/hissl \
      --pwd /hissl/tools/reproduce_deepsmile/4_create_splits_for_tcga_bc \
      $SINGULARITYIMAGE \
      python add_suffix_for_mask_paths.py
