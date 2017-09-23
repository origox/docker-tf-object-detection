FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04

MAINTAINER origox

# TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python \
        python-dev \
        rsync \
        software-properties-common \
        unzip \
        git \
        protobuf-compiler \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip --no-cache-dir install \
        tensorflow-gpu \
        pillow \
        lxml \
        h5py \
        ipykernel \
        jupyter \
        matplotlib \
        numpy \
        pandas \
        scipy \
        sklearn \
        && \
    python -m ipykernel.kernelspec

RUN  protoc --version 

RUN git clone https://github.com/tensorflow/models.git /opt/tensorflow-models
WORKDIR /opt/tensorflow-models/research    
RUN     protoc object_detection/protos/*.proto --python_out=.
ENV     PYTHONPATH $PYTHONPATH:/opt/tensorflow-models/research:/opt/tensorflow-models/research/slim

# Set up our notebook config.
####COPY jupyter_notebook_config.py /root/.jupyter/

# Copy sample notebooks.
####COPY notebooks /notebooks

# Jupyter has issues with being run directly:
#   https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.
####COPY run_jupyter.sh /

    # For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

#### WORKDIR "/notebooks"

CMD ["python", "object_detection/builders/model_builder_test.py"]
