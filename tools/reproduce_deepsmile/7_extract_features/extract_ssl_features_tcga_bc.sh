#!/bin/bash

# Run as
# ~/hissl/tools/reproduce_deepsmile/7_extract_features$ bash extract_ssl_features_tcga_bc.sh <FOLD>
# ~/hissl/tools/reproduce_deepsmile/7_extract_features$ bash extract_ssl_features_tcga_bc.sh 0
# ~/hissl/tools/reproduce_deepsmile/7_extract_features$ bash extract_ssl_features_tcga_bc.sh 1
# ~/hissl/tools/reproduce_deepsmile/7_extract_features$ bash extract_ssl_features_tcga_bc.sh 2
# ~/hissl/tools/reproduce_deepsmile/7_extract_features$ bash extract_ssl_features_tcga_bc.sh 3
# ~/hissl/tools/reproduce_deepsmile/7_extract_features$ bash extract_ssl_features_tcga_bc.sh 4

#ARGUMENTS TO SCRIPT
FOLD=$1

if [ $FOLD == '' ]; then
  echo "Fold is not given. Please give the fold (0, 1, 2, 3, 4) as the first argument of the script "
  exit 1
fi

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
LOAD_WEIGHTS_FROM="/hissl/model_zoo/tcga-bc/simclr-224px-114mpp-shufflenet_v2_x1_0/fold${FOLD}_epoch60.torch"
CONFIG_YAML=deepsmile/extract-features/tcga-bc/extract_shufflenetv2x1_0_bc_224px_114mpp

#NAMING
NAME="deepsmile/feature_extraction/tcga-bc/ssl/fold${FOLD}"

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



