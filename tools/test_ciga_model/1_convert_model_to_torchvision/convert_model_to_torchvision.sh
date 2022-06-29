#!/bin/bash

# Use as
# bash convert_model_to_torchvision.sh

# Use the singularity image to tile with DLUP
SINGULARITYIMAGE=../../../hissl_deepsmile.sif

singularity exec --no-home \
  --bind ../../../../hissl:/hissl \
  --pwd /hissl/model_zoo/ciga/ \
  $SINGULARITYIMAGE \
  python convert_ciga_model_to_torchvision.py
