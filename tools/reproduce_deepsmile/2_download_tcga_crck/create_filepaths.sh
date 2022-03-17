#!/bin/bash

SINGULARITYIMAGE=../../../hissl_deepsmile.sif

find train -name "*.png" > train_paths.txt
echo "Created train_paths.txt"
find test -name "*.png" > test_paths.txt
echo "Created test_paths.txt"

# Has to be run through Docker since VISSL expects the filepaths to be saved as a .np object
singularity exec --no-home \
      --bind $PWD:$PWD \
      --pwd $PWD \
      $SINGULARITYIMAGE \
      python create_filepaths.py
