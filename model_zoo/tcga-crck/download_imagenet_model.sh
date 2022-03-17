#!/bin/bash

# run as
# ~/hissl/model_zoo/tcga-crck$ bash download_imagenet_model.sh

SINGULARITYIMAGE=../../hissl_deepsmile.sif

export TORCH_HOME=. && singularity exec --no-home \
      --bind ../../../hissl:/hissl \
      --pwd /hissl/model_zoo/tcga-bc \
      $SINGULARITYIMAGE \
      python download_imagenet_model.py
