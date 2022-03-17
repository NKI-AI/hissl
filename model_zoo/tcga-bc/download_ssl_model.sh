#!/bin/bash

# run as
# ~/hissl/model_zoo/tcga-bc$ bash download_ssl_model.sh

mkdir tcga-bc-224px-114mpp-shufflenet && cd tcga-bc-224px-114mpp-shufflenet || exit
wget https://s3.aiforoncology.nl/deepsmile/models/tcga-bc-224px-114mpp-shufflenet/fold0_epoch60.torch ./
wget https://s3.aiforoncology.nl/deepsmile/models/tcga-bc-224px-114mpp-shufflenet/fold1_epoch60.torch ./
wget https://s3.aiforoncology.nl/deepsmile/models/tcga-bc-224px-114mpp-shufflenet/fold2_epoch60.torch ./
wget https://s3.aiforoncology.nl/deepsmile/models/tcga-bc-224px-114mpp-shufflenet/fold3_epoch60.torch ./
wget https://s3.aiforoncology.nl/deepsmile/models/tcga-bc-224px-114mpp-shufflenet/fold4_epoch60.torch ./
