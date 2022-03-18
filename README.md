HISSL: HIstology Self-Supervised Learning
==================

=== WORK IN PROGRESS ===

- Submodule initialization does not work because DLUP is not yet publicly available
- Current scripts with singularity calls might not work since DLUP is installed as editable and the entire hissl repo is mounted on the singularity, meaning there will be an empty DLUP directory
  - It is recommended to remove the `--bind $HISSL_ROOT:/hissl` from the singularity options for the time being, meaning changes you make to `hissl` are not reflected inside the container. This will allow you to run all the DeepSMILE reproduction scripts.

=========================

HISSL performs self-supervised pre-training of a feature extractor on histopathology data. It is
used for _DeepSMILE: Contrastive self-supervised pre-training benefits MSI and HRD
classification directly from H&E whole-slide images in colorectal and breast cancer_, and is meant to
1. allow reproduction of the results of DeepSMILE
2. be used on other datasets and other tasks by other researchers

Essentially, the repository contains the following:
1. DLUP (third_party/dlup): Deep Learning Utilities for Pathology. This is a repository that eases Whole-Slide Image preprocessing and can create datasets to read tiles from WSIs directly without any preprocessing.
2. A fork of [VISSL](https://github.com/facebookresearch/vissl/) (third_party/vissl). VISSL is a repository that allows high-performant self-supervised learning using
a large variety of state of the art self-supervised learning methods. The fork contains custom data sources (dataset classes) and
saves the features in `h5` format with additional metadata.
3. A docker image (docker/README.md) that has the above repositories properly installed, so that no complex set-up is required, and so that
the pre-training can be run on any OS.
4. Reproduction scripts (tools/reproduce_deepsmile) that can be run using `bash` that perform all the downloading, preprocessing, pretraining, and feature extraction steps for the feature learning part of _DeepSMILE: Contrastive self-supervised pre-training benefits MSI and HRD
classification directly from H&E whole-slide images in colorectal and breast cancer_
5. The pre-trained weights of the models trained for DeepSMILE .

* Free software: MIT license

Installation
--------
* Please use docker. See `docker/README.md`

Reproduce DeepSMILE feature extractors
--------------------------------------
Run `tools/reproduce_deepsmile.sh` on
- a linux server
- with more than 5TB storage space
- with 1-4 CUDA-enabled GPUs
- and `singularity` [installed](https://sylabs.io/guides/3.5/user-guide/quick_start.html)

This script will
0. Check that you have the singularity container
1. Download all TCGA-BC WSIs from the TCGA repository
2. Precompute masks for TCGA-BC using DLUP
3. Download TCGA-CRCk tiles from Zenodo
4. Create train-val-test splits for TCGA-BC using a label file from Kather (2019)
5. Pretrain (5x) ShufflenetV2x1_0 on TCGA-BC. These models should be similar to those downloaded by `model_zoo/tcga-bc/download_model.sh`
6. Pretrain (1x) Resnet18 on TCGA-CRCk. This model should be similar to the one downloaded by `model_zoo/tcga-crck/download_model.sh`
7. Extract and save all features for TCGA-BC and TCGA-CRCk

Changes to VISSL for HISSL
--------------------------
Our fork of VISSL contains some changes to be used for histopathology data. In summary:
- We add a ShuffleNet backbone (third_party/vissl/vissl/models/trunks/hissl_shufflenet.py)
- We add a dataset for TCGA-CRCk (third_party/vissl/vissl/data/kather_msi_dataset.py)
- We add a DLUP dataset to read tiles directly from WSIs and load/compute masks (third_party/vissl/vissl/data/dlup_dataset.py)
- We add saving of features as H5 datasets for both TCGA-CRCk and TCGA-BC (third_party/vissl/vissl/trainer/trainer_main_hissl.py)

Reproduce classifiers
--------------------
See [dlup-lightning-mil](https://github.com/nki-ai/dlup-lightning-mil)


