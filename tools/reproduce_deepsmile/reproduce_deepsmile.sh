#!/bin/bash

run_line()
{
    local EXECLINE=$2
    if [ $EXECLINE == 'y' ]; then
        eval $1
    elif [ $EXECLINE == 'n' ]; then
        echo "We will not execute the line."
    else
        echo "The answer to the previous prompt was not 'n'. We will execute the line."
        eval $1
    fi
    return
}

# Check if singularity image is available
cd 0_check_singularity && bash check_singularity.sh && cd ..

# Download all BC images from TCGA
read -e -p "Download TCGA-BC WSIs? [(y)/n]: " -i "y" EXECLINE
DOWNLOAD_TCGA="cd 1_download_tcga_bc && bash download_tcga_bc.sh && cd .."
run_line "$DOWNLOAD_TCGA" $EXECLINE

# Download all CRC tiles from zenodo
read -e -p "Download and unzip TCGA-CRCk tiles? [(y)/n]: " -i "y" EXECLINE
DOWNLOAD_TCGACRCK="cd 2_download_tcga_crck && download_tcga_crck.sh & cd .."
run_line "$DOWNLOAD_TCGACRCK" $EXECLINE

# Create filepaths for the TCGA-CRCk tiles and save them to a .np object as used by VISSL's disk_filelist dataset
read -e -p "Create filepaths for TCGA-CRCk tiles? [(y)/n]: " -i "y" EXECLINE
PATHS_TCGACRCK="cd 2_download_tcga_crck && bash create_filepaths.sh & cd .."
run_line "$PATHS_TCGACRCK" $EXECLINE

# Pre-compute and save masks for the TCGA BC WSIs
read -e -p "Precompute the masks for all TCGA-BC WSIs in the  [(y)/n]: " -i "y" EXECLINE
RUN_MASKS="cd 3_compute_masks_for_tcga_bc && bash mask_and_check_tiles.sh 1.14 224 fesi 0.5 ../1_download_tcga_bc $PWD && cd .."
run_line "$RUN_MASKS" $EXECLINE

## Create splits for TCGA-BC as is required for SSL
read -e -p "Create splits for TCGA-BC? [(y)/n]: " -i "y" EXECLINE
RUN_SPLITS="cd 4_create_splits_for_tcga_bc && bash create_splits.sh & cd .."
run_line "$RUN_SPLITS" $EXECLINE
#
# Pretrain on CRCk. Will take ~4 days on 1 node with 1 GeForce 1080Ti for 100 epochs
#NUM_EPOCHS_CRCK=100
read -e -p "Pretrain an encoder on TCGA-CRCk? [(y)/n]: " -i "y" EXECLINE

if [ $EXECLINE != 'n' ]; then
    read -e -p "If so, for how many epochs? (100 is DeepSMILE default): " -i "100" NUM_EPOCHS_CRCK
fi
PRETRAIN_CRCK="cd 5_pretrain_crck && bash pretrain_crck.sh ${NUM_EPOCHS_CRCK} && cd .."
run_line "$PRETRAIN_CRCK" $EXECLINE
#
## Pretrain on TCGA-BC. Will take ~4 days on 1 node with 4 TitanRTX for 40 epochs
NUM_EPOCHS_TCGABC=1 # 40 epochs will reproduce deepsmile

FOLDS=(0 1 2 3 4)
for FOLD in "${FOLDS[@]}"
do
    read -e -p "Pretrain an encoder on TCGA-BC fold ${FOLD}? [(y)/n]: " -i "y" EXECLINE
    PRETRAIN_BC="cd 6_pretrain_tcga_bc && bash pretrain_bc.sh ${NUM_EPOCHS_TCGABC} ${FOLD} && cd .."
    run_line "$PRETRAIN_BC" $EXECLINE
done

#
# Extract all features required for the MIL pipelines
cd 7_extract_features

read -e -p "Extract ImageNet features for all tiles of TCGA-CRCk? [(y)/n]: " -i "y" EXECLINE
run_line "bash extract_imagenet_features_tcga_crck.sh" $EXECLINE

read -e -p "Extract SSL features for all tiles of TCGA-CRCk? [(y)/n]: " -i "y" EXECLINE
run_line "bash extract_ssl_features_tcga_crck.sh" $EXECLINE

read -e -p "Extract ImageNet features for all tiles of TCGA-BC? [(y)/n]: " -i "y" EXECLINE
run_line "bash extract_imagenet_features_tcga_bc.sh" $EXECLINE

for FOLD in "${FOLDS[@]}"
do
    read -e -p "Extract SSL features with extractor trained on the train-val set of fold ${FOLD} for all tiles of TCGA-BC? [(y)/n]: " -i "y" EXECLINE
    run_line "bash extract_ssl_features_tcga_bc.sh ${FOLD}" $EXECLINE
done

cd ..

echo "You finished pre-training and extracting features. To reproduce the classification experiments, please check out the classification
repository as described in the README in the root of this repository."

exit 0









