# Use NVIDIA CUDA image with cuDNN on Ubuntu 24.04
FROM nvidia/cuda:13.0.2-cudnn-runtime-ubuntu24.04

# Specify Python version
ENV PYTHON_VERSION=3.12.12
ENV PYTHON_INSTALL_DIR=/opt/python-${PYTHON_VERSION}
ENV PATH=${PYTHON_INSTALL_DIR}/bin:${PATH}

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    git \
    build-essential \
    wget \
    ca-certificates \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    libncurses5-dev \
    libncursesw5-dev \
    liblzma-dev \
    tk-dev \
    uuid-dev \
    libgdbm-dev \
    libdb5.3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download, build and install Python
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations --with-ensurepip=install --prefix=${PYTHON_INSTALL_DIR} && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf Python-${PYTHON_VERSION}*

# Ensure python3 and pip3 point to our new version
RUN ln -sf ${PYTHON_INSTALL_DIR}/bin/python3.12 /usr/local/bin/python3 && \
    ln -sf ${PYTHON_INSTALL_DIR}/bin/pip3.12 /usr/local/bin/pip3

WORKDIR /

RUN pip3 install --no-input -U pip

RUN pip3 install pip-tools --no-input --no-cache-dir
RUN pip3 cache purge

COPY requirements-runpod.txt .

RUN pip-sync requirements-runpod.txt
RUN pip3 cache purge

RUN pip3 install --no-input --no-deps --no-cache-dir git+https://github.com/facebookresearch/demucs@e976d93ecc3865e5757426930257e200846a520a#egg=demucs

RUN pip3 install --force-reinstall --no-input --no-cache-dir \
torch==2.11.0 \
torchvision==0.26.0 \
torchaudio==2.11.0 \
--index-url https://download.pytorch.org/whl/cu130

COPY handler.py .

CMD ["python3", "-u", "/handler.py"]
