#!/bin/bash

FILE=../../../hissl_deepsmile.sif
if test -f "$FILE"; then
    echo "$FILE exists. This will be used for the rest of the scripts."
else
    echo "$FILE does not exist. Please follow ~/hissl/docker/README.md to set up a singularity image. Aborting."
    exit 1
fi

