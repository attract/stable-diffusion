FROM nvidia/cuda:11.6.2-devel-ubuntu20.04
#FROM nvidia/cuda:12.3.1-devel-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt-get install -y ffmpeg wget git curl python3-pip libgl1 libglib2.0-0

# Install conda from this docs -> https://docs.conda.io/projects/miniconda/en/latest/
RUN mkdir -p ~/miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
RUN bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
RUN rm -rf ~/miniconda3/miniconda.sh
RUN ~/miniconda3/bin/conda init bash

# Install python and stablediffusion
RUN ~/miniconda3/bin/conda install -y python=3.10.6
RUN ~/miniconda3/bin/conda install -y pytorch==1.12.1 torchvision==0.13.1 -c pytorch
# RUN ~/miniconda3/bin/conda install -y pytorch==2.1.0 torchvision==0.16.0 -c pytorch
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

RUN . ~/miniconda3/bin/activate \
    && pip install git+https://github.com/huggingface/transformers

COPY ./req.txt /requirements/req.txt
RUN . ~/miniconda3/bin/activate \
    && pip install --no-cache -r /requirements/req.txt

# Install xformers
RUN . ~/miniconda3/bin/activate \
    && pip install git+https://github.com/facebookresearch/xformers.git

# Install ffmpeg
RUN . ~/miniconda3/bin/activate \
    && ~/miniconda3/bin/conda install -c conda-forge x264=='1!161.3030' ffmpeg=4.4.0 libiconv \
    && export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1 \
    && ~/miniconda3/bin/conda install cryptography