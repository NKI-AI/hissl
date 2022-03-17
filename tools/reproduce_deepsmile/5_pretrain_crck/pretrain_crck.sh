#!/bin/bash

ROOT=../../../../hissl

#HARDWARE SETUP
NUM_WORKERS=3  # Increase this if GPU utilization is low and if your CPU hardware allows this.
NUM_NODES=1
NUM_GPUS=1
BATCH_SIZE_PER_GPU=128
NUM_EPOCHS=$1

#DATASET SPECIFIC
DATA_PATHS_ROOT=$ROOT/tools/reproduce_deepsmile/1_download_tcga_crck/train

#EXPERIMENT SPECIFIC
CONFIG_YAML=deepsmile/pretraining/tcga-crck/gpu_rn18_simclr_on_tcga_crck # Searched for in ~/hissl/configs/config
NAME=deepsmile/pretraining/tcga-crck
LOG_DIR=$ROOT/logs
SINGULARITYIMAGE=../../../hissl_deepsmile.sif

#Start a new experiment from scratch
CHECKPOINT_ID=$(date +"%Y-%m-%d-%Hh-%Mm-%Ss")
CHECKPOINT_DIR=$LOG_DIR/$NAME/checkpoints/$CHECKPOINT_ID

echo "Writing results to $CHECKPOINT_DIR"

#TODO set to use tensorboard
run_train()
{
  echo "python -u /hissl/tools/run_distributed_engines_hissl.py \
      hydra.verbose=true \
      config=$CONFIG_YAML \
      config.CHECKPOINT.DIR=$CHECKPOINT_DIR \
      config.DISTRIBUTED.NUM_NODES=$NUM_NODES \
      config.DISTRIBUTED.NUM_PROC_PER_NODE=$NUM_GPUS \
      config.OPTIMIZER.num_epochs=$NUM_EPOCHS \
      config.DATA.NUM_DATALOADER_WORKERS=$NUM_WORKERS \
      config.DATA.TRAIN.BATCHSIZE_PER_REPLICA=$BATCH_SIZE_PER_GPU \
      config.HOOKS.TENSORBOARD_SETUP.USE_TENSORBOARD=False"
}

slurm_submit()
{
  singularity exec --no-home --nv \
      --bind $ROOT:/hissl \
      --pwd /hissl \
      $SINGULARITYIMAGE \
      $COMMAND
}

COMMAND=$(run_train)
echo $(slurm_submit $COMMAND)



