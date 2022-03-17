#!/bin/bash

#EXPERIMENT GENERIC
HISSL_ROOT=../../../../hissl
EXPERIMENT_DIR=$HISSL_ROOT/logs
SINGULARITYIMAGE=$HISSL_ROOT/hissl_deepsmile.sif

#HARDWARE SETUP
NUM_WORKERS=4
NUM_NODES=1
NUM_GPUS=1
BATCH_SIZE_PER_GPU=256

#EXPERIMENT SPECIFIC
LOAD_WEIGHTS_FROM=$HISSL_ROOT/model_zoo/tcga-crck/resnet18_simclr_epoch99.torch
CONFIG_YAML=deepsmile/extract-features/tcga-crck/extract_rn18_crck

#---naming
NAME=deepsmile/feature_extraction/tcga-crck/ssl

run_train()
{
  echo "python -u /hissl/tools/run_distributed_engines_hissl.py \
      hydra.verbose=true \
      config=$CONFIG_YAML \
      config.DATA.TRAIN.BATCHSIZE_PER_REPLICA=$BATCH_SIZE_PER_GPU \
      config.DATA.TEST.BATCHSIZE_PER_REPLICA=$BATCH_SIZE_PER_GPU \
      config.CHECKPOINT.DIR=/hissl/logs/$NAME \
      config.DATA.NUM_DATALOADER_WORKERS=$NUM_WORKERS \
      config.DISTRIBUTED.NUM_NODES=$NUM_NODES \
      config.DISTRIBUTED.NUM_PROC_PER_NODE=$NUM_GPUS \
      config.MODEL.WEIGHTS_INIT.PARAMS_FILE=$LOAD_WEIGHTS_FROM"
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



