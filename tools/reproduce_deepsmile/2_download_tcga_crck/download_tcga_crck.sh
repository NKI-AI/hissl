#!/bin/bash

# Use as
# bash download_tcga_crck.sh

isPackageNotInstalled() {
    dpkg --status $1 &> /dev/null
    if [ $? -eq 0 ]; then
    echo "$1: Already installed"
    else
    sudo apt-get install -y $1
    fi
    }

isPackageNotInstalled zip
isPackageNotInstalled wget
isPackageNotInstalled find

mkdir test && cd test
wget https://zenodo.org/record/2530835/files/CRC_DX_TEST_MSIMUT.zip && echo "Unzipping CRC_DX_TEST_MSIMUT..." && unzip -q CRC_DX_TEST_MSIMUT.zip && rm CRC_DX_TEST_MSIMUT.zip
wget https://zenodo.org/record/2530835/files/CRC_DX_TEST_MSS.zip && echo "Unzipping CRC_DX_TEST_MSS..." && unzip -q CRC_DX_TEST_MSS.zip && rm CRC_DX_TEST_MSS.zip
cd ..
mkdir train && cd train
wget https://zenodo.org/record/2530835/files/CRC_DX_TRAIN_MSIMUT.zip && echo "Unzipping CRC_DX_TRAIN_MSIMUT..." && unzip -q CRC_DX_TRAIN_MSIMUT.zip  && rm CRC_DX_TRAIN_MSIMUT.zip
wget https://zenodo.org/record/2530835/files/CRC_DX_TRAIN_MSS.zip && echo "Unzipping CRC_DX_TRAIN_MSIMUT..." && unzip -q CRC_DX_TRAIN_MSS.zip && rm CRC_DX_TRAIN_MSS.zip
cd ..



