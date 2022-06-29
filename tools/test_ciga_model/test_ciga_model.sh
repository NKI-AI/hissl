#!/bin/bash

cd 1_convert_model_to_torchvision
bash 1_convert_model_to_torchvision
cd ../2_extract_features
bash extract_ciga_features_tcga_bc.sh
bash extract_ciga_features_tcga_crck.sh
