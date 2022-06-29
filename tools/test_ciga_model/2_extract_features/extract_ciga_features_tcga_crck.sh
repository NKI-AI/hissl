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
LOAD_WEIGHTS_FROM=/hissl/model_zoo/ciga/resnet18_ciga_statedict.torch
CONFIG_YAML=ciga/extract-features/tcga-crck/extract_ciga_rn18_crck

#NAMING
NAME=deepsmile/feature_extraction/tcga-crck/ciga

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



