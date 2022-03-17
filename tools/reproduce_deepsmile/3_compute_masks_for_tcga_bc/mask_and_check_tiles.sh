#!/bin/bash

# Use as
# bash mask_and_check_tiles.sh 1.14 224 fesi 0.5 /(relative/)path/to/hissl/tools/reproduce_deepsmile/1_download_tcga_bc /absolute/path/to/hissl/tools/reproduce_deepsmile

# Use the singularity image to tile with DLUP
SINGULARITYIMAGE=../../../hissl_deepsmile.sif

# Input arguments used as hyperparameters for computing the mask and showing the tiles on the thumbnails
MPP=$1
TILE_SIZE=$2
MASK_FUNC=$3
FOREGROUND_THRESHOLD=$4
SOURCE_DIRECTORY=$5
MOUNT_DIRECTORY=$6

CURRENT_FILENAME_WITH_EXT=$(basename $BASH_SOURCE)

echo "Starting $CURRENT_FILENAME_WITH_EXT"

CURRENT_FILENAME=$(basename $CURRENT_FILENAME_WITH_EXT .sh)

# Setting the directory name to save the masks in
CURRENT_FILENAME_WITH_PARAMS="$CURRENT_FILENAME"_mpp"$MPP"_ts"$TILE_SIZE"_"$MASK_FUNC"_"$FOREGROUND_THRESHOLD"

# Set directory containing images
IMG_SOURCE_DIRECTORY="$SOURCE_DIRECTORY/images"

# Set directory that will contain masks
OUTPUT_DIRECTORY="$SOURCE_DIRECTORY/masks/$CURRENT_FILENAME_WITH_PARAMS"
LEN_SOURCE_DIRECTORY=${#IMG_SOURCE_DIRECTORY}

echo "Writing to $OUTPUT_DIRECTORY..."

# Search for all .svs in the img source directory, and loop over all results
EXTENSION=".svs"
find $IMG_SOURCE_DIRECTORY -name "*$EXTENSION" | while read line
do
    CHARS_TO_STRIP=$(expr $LEN_SOURCE_DIRECTORY + 1)
    RELATIVE_DIR=${line:$CHARS_TO_STRIP} # Strip the source directory from the found file path and the /
    RELATIVE_DIR_WITHOUT_FILE_EXTENSION=${RELATIVE_DIR%$EXTENSION} # Strip the extension from the found file path

    # Go over a single WSI, compute the mask, and save tiling metadata without saving the tiles.
    echo "Preprocessing $line ..."

    # Pass the found filepath as input
    # Save the output in the same tree structure as source directory

    #TODO the $PWD is not good, because that includes ~
    singularity exec --no-home \
      --bind ../../../../hissl:/hissl \
      --pwd /hissl/tools/reproduce_deepsmile/3_compute_masks_for_tcga_bc \
      $SINGULARITYIMAGE \
      dlup wsi tile \
        --mask-func $MASK_FUNC \
        --do-not-save-tiles \
        --mpp $MPP \
        --tile-size $TILE_SIZE \
        --foreground-threshold $FOREGROUND_THRESHOLD \
        $line \
        $OUTPUT_DIRECTORY/$RELATIVE_DIR_WITHOUT_FILE_EXTENSION
done
