#TODO rebuild docker with the latest hissl and dlup so it works out of the box.
#TODO rebuild docker with sklearn so that entire pipeline can be run

ARG CUDA="11.1"
ARG CUDNN="8"

FROM nvidia/cuda:${CUDA}-cudnn${CUDNN}-devel-ubuntu18.04
ARG CUDA
ARG CUDNN
ARG PYTHON="3.8"
ARG UNAME="hissl"
ARG BUILD_WORKERS="4"

ENV CUDA_PATH /usr/local/cuda
ENV CUDA_ROOT /usr/local/cuda/bin
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib64

# Install build tools
RUN apt-get -qq update \
    && apt-get update && apt-get install -y libxrender1 build-essential sudo \
    autoconf automake libtool pkg-config libtiff-dev libopenjp2-7-dev libglib2.0-dev \
    libxml++2.6-dev libsqlite3-dev libgdk-pixbuf2.0-dev libgl1-mesa-glx git wget rsync \
    fftw3-dev liblapacke-dev libpng-dev libopenblas-dev libxext-dev jq sudo \
    libfreetype6 libfreetype6-dev \
    # Purge pixman and cairo to be sure
    && apt-get remove libpixman-1-dev libcairo2-dev \
    && apt-get purge libpixman-1-dev libcairo2-dev \
    && apt-get autoremove && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    # ^-- removes all unused apt-get stuff

# Install pixman 0.40, as Ubuntu repository holds a version with a bug which can cause difficulties reading thumbnails
RUN cd /tmp \
    && wget https://www.cairographics.org/releases/pixman-0.40.0.tar.gz \
    && tar xvf pixman-0.40.0.tar.gz && rm pixman-0.40.0.tar.gz && cd pixman-0.40.0 \
    && ./configure && make -j$BUILD_WORKERS && make install \
    && cd /tmp && rm -rf pixman-0.40.0

# Install cairo 1.16
RUN cd /tmp \
    && wget https://www.cairographics.org/releases/cairo-1.16.0.tar.xz \
    && tar xvf cairo-1.16.0.tar.xz && rm cairo-1.16.0.tar.xz && cd cairo-1.16.0 \
    && ./configure && make -j$BUILD_WORKERS && make install \
    && cd /tmp && rm -rf cairo-1.16.0

# Install OpenSlide for NKI-AI repository.
RUN git clone https://github.com/NKI-AI/openslide.git /tmp/openslide \
    && cd /tmp/openslide \
    && autoreconf -i \
    && ./configure && make -j$BUILD_WORKERS && make install && ldconfig \
    && cd /tmp && rm -rf openslide

RUN mkdir /users && echo $UNAME \
    && adduser --disabled-password --gecos '' --home /users/$UNAME $UNAME \
    && adduser $UNAME sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir /$UNAME && chown $UNAME:$UNAME /$UNAME

USER $UNAME

WORKDIR /tmp

# Install miniconda, which we use to save all static python packages
RUN cd /tmp \
    && wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh

ENV PATH "/users/$UNAME/miniconda3/bin:$PATH:$CUDA_ROOT"


# TODO Rebuild the file, repush to dockerhub, remake into singularity to include tensorboard so we can use tensorboard logging
# Setup python packages
RUN conda update -n base conda -yq \
    && conda install python=${PYTHON} \
    && conda install astunparse ninja setuptools cmake future requests dataclasses \
    && conda install pyyaml mkl mkl-include setuptools cffi typing boost \
    && conda install tqdm jupyter matplotlib scikit-image pandas joblib -yq \
    && conda install typing_extensions \
    && conda install pytorch torchvision cudatoolkit=11.1 -c pytorch-lts -c nvidia \
    && conda install -c conda-forge tensorboard \
    # Sklearn is required for creating the data splits \
    && conda install scikit-learn==0.24.2 \
    && conda clean -ya \
    && python -m pip install numpy==1.21 tifftools -q \
    # Install openslide-python from NKI-AI
    && python -m pip install git+https://github.com/NKI-AI/openslide-python.git

# Copy files into the docker
COPY --chown=$UNAME:$UNAME . /$UNAME

# Switch to local user
ENV PYTHONPATH /$UNAME

# Install vissl according to https://github.com/facebookresearch/vissl/blob/main/INSTALL.md,
# except that we use our own vissl submodule
WORKDIR /$UNAME/third_party/vissl
RUN python -m pip install -r requirements.txt \
    && python -m pip install opencv-python \
    && python -m pip install classy-vision@https://github.com/facebookresearch/ClassyVision/tarball/main \
    # install vissl dev mode (e stands for editable)
    && python -m pip install -e .

# Install dlup
WORKDIR /$UNAME/third_party/dlup
RUN python -m pip install -e ".[dev]"

# Install hissl
WORKDIR /$UNAME
RUN python -m pip install -e .

# Install latest numpy with nice typing
RUN python -m pip install numpy==1.21
RUN python -m pip install h5py
RUN conda install pytorch=1.8.2 torchvision cudatoolkit=11.1 -c pytorch-lts -c nvidia

# Verify installation
RUN python -c 'import hissl'
RUN python -c 'import vissl'
RUN python -c 'import dlup'
RUN python -c 'import openslide'

WORKDIR /$UNAME


# Provide an open entrypoint for the docker
ENTRYPOINT $0 $@
