FROM nvcr.io/nvidia/tritonserver:22.07-py3

# see .dockerignore to check what is transfered

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    python3-dev \
    python3-distutils \
    python3-venv \
    python3-pip && \
    apt-get clean

ARG UID=1001
ARG GID=1001
RUN addgroup --gid $GID ubuntu && \
    useradd -d /home/ubuntu -ms /bin/bash -g ubuntu -G sudo -u $UID ubuntu

WORKDIR /build
RUN pip3 install -U pip --no-cache-dir && \
    pip3 install --pre torch --force-reinstall --index-url https://download.pytorch.org/whl/nightly/cu117 --no-cache-dir && \
    pip3 install sentence-transformers notebook ipywidgets --no-cache-dir

WORKDIR /transformer_deploy

COPY ./setup.py ./setup.py
COPY ./requirements.txt ./requirements.txt
COPY ./requirements_gpu.txt ./requirements_gpu.txt
COPY ./src/__init__.py ./src/__init__.py
COPY ./src/transformer_deploy/__init__.py ./src/transformer_deploy/__init__.py

RUN pip3 install -r requirements.txt && \
    pip3 install nvidia-pyindex pytorch-quantization --no-cache-dir && \
    pip3 install -r requirements_gpu.txt

COPY ./ ./
RUN pip3 install .

## Switch to ubuntu user by default.
RUN chown -R ubuntu:ubuntu /transformer_deploy
RUN chmod 755 /transformer_deploy
USER ubuntu
