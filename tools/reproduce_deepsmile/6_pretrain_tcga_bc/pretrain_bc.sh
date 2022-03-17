#!/bin/bash

HISSL_ROOT=../../../../hissl

#HARDWARE SETUP FOR TESTING THE SCRIPTS
NUM_WORKERS=4 # 18
NUM_NODES=1 # 1
NUM_GPUS=1 # 4
BATCH_SIZE_PER_GPU=256 # 256
NUM_EPOCHS=$1 # 40
FOLD=$2 # 0, 1, 2, 3, or 4

#EXPERIMENT GENERIC
SINGULARITYIMAGE=../../../hissl_deepsmile.sif

#EXPERIMENT SPECIFIC

#---logging
LOG_DIR=$HISSL_ROOT/logs
CHECKPOINT_ID=$(date +"%Y-%m-%d-%Hh-%Mm-%Ss")
NAME=deepsmile/pretraining/tcga-bc/fold$FOLD # Set the name to the directory that the results are saved in
CHECKPOINT_DIR=$LOG_DIR/$NAME/checkpoints

#---data
# File holding the relative paths
DATA_PATHS_FILE="/hissl/tools/reproduce_deepsmile/4_create_splits_for_tcga_bc/splits/paths_trainval_fold-${FOLD}_subset-1.0.txt"
MASK_FILE_PATHS="/hissl/tools/reproduce_deepsmile/4_create_splits_for_tcga_bc/splits/paths_trainval_fold-${FOLD}_subset-1.0_masks.txt"

# Setting the root from where to search for the relative paths

# WSIs
DATA_ROOT=/hissl/tools/reproduce_deepsmile/1_download_tcga_bc
DATA_ROOT_DIR=$DATA_ROOT/images

# Masks
MASKS_DIR=mask_and_check_tiles_mpp1.14_ts224_fesi_0.5
MASKS_ROOT_DIR=$DATA_ROOT/masks/$MASKS_DIR

# Config
CONFIG_YAML=deepsmile/pretraining/tcga-bc/gpu_shufflenetv2x1_0_simclr_on_tcga_brca_dx_224px_114mpp


#TODO Allow use of tensorboard
run_train()
{
  echo "python -u /hissl/tools/run_distributed_engines_hissl.py \
      hydra.verbose=true \
      config=$CONFIG_YAML \
      config.CHECKPOINT.DIR=$CHECKPOINT_DIR \
      config.DISTRIBUTED.NUM_NODES=$NUM_NODES \
      config.DISTRIBUTED.NUM_PROC_PER_NODE=$NUM_GPUS \
      config.DATA.NUM_DATALOADER_WORKERS=$NUM_WORKERS \
      config.DATA.TRAIN.DATA_PATHS=[$DATA_PATHS_FILE] \
      config.DATA.TRAIN.BATCHSIZE_PER_REPLICA=$BATCH_SIZE_PER_GPU \
      config.DATA.DLUP.ROOT_DIR=$DATA_ROOT_DIR \
      config.DATA.DLUP.MASK_PARAMS.MASK_ROOT=$MASKS_ROOT_DIR \
      config.DATA.DLUP.MASK_PARAMS.MASK_FILE_PATHS=$MASK_FILE_PATHS \
      config.DATA.DLUP.MASK_PARAMS.MASK_FACTORY=load_from_disk \
      config.HOOKS.TENSORBOARD_SETUP.USE_TENSORBOARD=False"
}

slurm_submit()
{
  singularity exec --no-home --nv \
      --bind $HISSL_ROOT:/hissl \
      --pwd /hissl \
      $SINGULARITYIMAGE \
      $COMMAND
}

COMMAND=$(run_train)

echo $(slurm_submit $COMMAND)



