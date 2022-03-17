# How to

## Use the repository as-is, or with custom code changes

Pull the docker image from dockerhub:
```bash
docker pull yonischirris/deepsmile:hissl-latest
```

The docker and singularity images have the current version of the repository installed. Simply opening a shell in either of the containers
(e.g. `docker shell hissl:latest` for docker and `singularity --no-home --nv shell hissl_YYYYMMDD.sif` for singularity) will give you access
to all the code and installed modules.

HISSL, DLUP, and VISSL are installed as editables. If you make changes in any of these repositories on your local machine (this could be as simple as adding your own config file), one can simply bind
the locally changed `~/hissl` repository to `/hissl` in the container (adding e.g. `--bind ~/hissl:/hissl` as argument for singularity or `-v ~/hissl:/hissl` for docker).
Since the conda environment points to `/hissl`, `/hissl/third_party/vissl`, and `/hissl/third_party/dlup`, these changes will be reflected in all scripts that are run using, e.g.,
```bash
singularity exec --no-home --nv \
      --bind ~/hissl:/hissl \
      --pwd /hissl \
      hissl_YYYYMMDD.sif \
      python -u /hissl/tools/run_distributed_engines_hissl.py config=your_config
```

## Build the image
This may be a better option if you wish to make changes to the Dockerfile

| :warning: WARNING              |
|:-------------------------------|
| This is currently not possible |

1. Git clone this repo:
``` bash
git clone git@github.com:NKI-AI/hissl.git
```
2. From the project root (`cd hissl`), install the submodules:
``` bash
git submodule update --init --recursive
```
3. Build the docker image from the root directory with
``` bash
docker build -t hissl:latest -f docker/Dockerfile .
```

If you are on MacOS with an M1 chip, use the `--platform` option to build for linux platforms and to correctly compile low-level C libraries:
```bash
docker build --platform linux/amd64 -t hissl:latest -f docker/Dockerfile .
```

4. Convert to a singularity image for use on shared compute clusters (these generally do not allow root rights required by docker)
   1. Find the image ID of your container using `docker images`, for instance `zd21feda4b34`
   2. Dump the container to disk with `docker save zd21feda4b34 -o hissl_YYYYMMDD.tar`.
   3. [Install singularity](https://singularity-docs.readthedocs.io/en/latest/)
   4. Convert to singularity using `singularity build hissl_YYYYMMDD.sif docker-archive://hissl_YYYYMMDD.tar`
5. To run `~/hissl/tools/reproduce_deepsmile/reproduce_deepsmile.sh`, please ensure that the image is called `hissl_deepsmile.sif` and
is found in the root directory of this repository (`~/hissl/hissl_deepsmile.sif`).







