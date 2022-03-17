#!/bin/bash

#EXPERIMENT GENERIC
HISSL_ROOT=../../../../hissl
EXPERIMENT_DIR=$HISSL_ROOT/logs
SINGULARITYIMAGE=$HISSL_ROOT/hissl_deepsmile.sif

#HARDWARE SETUP
NUM_WORKERS=6
NUM_NODES=1
NUM_GPUS=1 # It's preferred to use a single GPU since we then end up with a single .h5 dataset
BATCH_SIZE_PER_GPU=1024

#EXPERIMENT SPECIFIC
LOAD_WEIGHTS_FROM=/hissl/model_zoo/tcga-bc/shufflenet_v2_x1_0_imagenet_statedict.torch
CONFIG_YAML=deepsmile/extract-features/tcga-bc/extract_shufflenetv2x1_0_bc_224px_114mpp

#NAMING
NAME=deepsmile/feature_extraction/tcga-bc/imagenet

run_train()
{
  echo "python -u /hissl/tools/run_distributed_engines_hissl.py \
      hydra.verbose=true \
      config=$CONFIG_YAML \
      config.DATA.TRAIN.BATCHSIZE_PER_REPLICA=$BATCH_SIZE_PER_GPU \
      config.CHECKPOINT.DIR=/hissl/logs/$NAME \
      config.DATA.NUM_DATALOADER_WORKERS=$NUM_WORKERS \
      config.DISTRIBUTED.NUM_NODES=$NUM_NODES \
      config.DISTRIBUTED.NUM_PROC_PER_NODE=$NUM_GPUS \
      config.MODEL.WEIGHTS_INIT.PARAMS_FILE=$LOAD_WEIGHTS_FROM \
      config.MODEL.WEIGHTS_INIT.SKIP_LAYERS=['num_batches_tracked'] \
      config.MODEL.WEIGHTS_INIT.APPEND_PREFIX='trunk._feature_blocks.' \
      config.MODEL.WEIGHTS_INIT.STATE_DICT_KEY_NAME=''"
}   # ^--- the last three options are specific to torchvision models

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



