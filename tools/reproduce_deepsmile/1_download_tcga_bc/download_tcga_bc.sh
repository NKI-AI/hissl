#!/bin/bash

# See documentation here: https://docs.gdc.cancer.gov/Data_Transfer_Tool/Users_Guide/Data_Download_and_Upload/

REL_PATH_TO_RESOURCES=../../../../resources/data/tcga_bc

mkdir -p images && cd images

$REL_PATH_TO_RESOURCES/gdc-client download -m $REL_PATH_TO_RESOURCES/gdc_manifest_all_BRCA_DX-2020-08-05.txt
