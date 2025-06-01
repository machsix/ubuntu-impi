FROM debian:12.11

LABEL org.opencontainers.image.authors="28209092+machsix@users.noreply.github.com>"

# Install fundamental packages
RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apt-transport-https \
    software-properties-common \
    gnupg \
    openssl \
    openssh-client \
    build-essential \
    gfortran \
    pkg-config \
    locales \
    zsh \
    curl \
    iputils-ping \
    rsync \
    fontconfig \
    doxygen \
    graphviz \
    tmux \
    ca-certificates \
    iproute2 \
    sudo \
    git \
    wget \
    gdb \
    bc \
    patch \
    unzip \
    unar \
    gzip \
    ca-certificates \
    xz-utils \
    zstd \
    bzip2 \
    lsb-release \
    reptyr \
    python3 \
    python3-dev \
    python3-venv \
    python3-distutils \
    python3-pip \
    cmake \
    libssl-dev libcurl4-openssl-dev \
    lua5.1 lua5.1-bitop liblua5.1-0-dev lua5.1-json lua5.1-lpeg-dev lua5.1-posix-dev lua5.1-term \
    tcl-dev tree bc file patchelf \
    vim-nox \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -fsSL https://github.com/mikefarah/yq/releases/download/v4.45.4/yq_linux_amd64.tar.gz -o yq.tar.gz && \
    tar -xzf yq.tar.gz && \
    mv yq_linux_amd64 /usr/local/bin/yq && \
    rm yq*


# Install Miniconda from conda-forge
ARG CONDA_INSTALL_DIR=/opt/python/miniforge3
WORKDIR /opt/pkgs/miniforge3
RUN curl -fsSL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -o miniconda.sh && \
    bash miniconda.sh -b -p ${CONDA_INSTALL_DIR} && \
    . /opt/python/miniforge3/etc/profile.d/conda.sh && \
    sed -i '/defaults/d' ${CONDA_INSTALL_DIR}/.condarc && \
    # conda config --system --set ssl_verify false 2>/dev/null && \
    conda install -y conda-libmamba-solver mamba python=3.11 && \
    conda config --system --set solver libmamba && \
    conda install -y numpy scipy matplotlib pandas tecio "libblas=*=*mkl" jupyterlab hdf5 python-lsp-ruff && \
    mkdir -p ${CONDA_INSTALL_DIR}/conda-meta && \
    echo "libblas=*=mkl" >> ${CONDA_INSTALL_DIR}/conda-meta/pinned && \
    echo "python 3.11.*" >> ${CONDA_INSTALL_DIR}/conda-meta/pinned


# install lmod
ARG LMOD_VERSION=8.7.60
WORKDIR /opt/pkgs
RUN curl -L https://github.com/TACC/Lmod/archive/refs/tags/${LMOD_VERSION}.tar.gz -o Lmod-${LMOD_VERSION}.tar.gz && \
    mkdir -p /opt/pkgs/lmod && \
    tar -C /opt/pkgs/lmod -xzf Lmod-${LMOD_VERSION}.tar.gz --strip-component=1 && \
    cd /opt/pkgs/lmod && \
    ./configure --prefix=/opt && \
    make install && \
    ln -s /opt/lmod/lmod/init/profile  /etc/profile.d/z00_lmod.sh && \
    ln -s /opt/lmod/lmod/init/cshrc    /etc/profile.d/z00_lmod.csh


# install intel oneAPI
WORKDIR /opt/pkgs/intel
ARG INTEL_VERSION=2023.2.0
RUN curl -L https://registrationcenter-download.intel.com/akdlm/IRC_NAS/0722521a-34b5-4c41-af3f-d5d14e88248d/l_HPCKit_p_2023.2.0.49440.sh \
    -o l_HPCKit_p_${INTEL_VERSION}.sh && \
    chmod +x l_HPCKit_p_${INTEL_VERSION}.sh && \
    ./l_HPCKit_p_${INTEL_VERSION}.sh  -a -s --eula accept && \
    curl -L https://registrationcenter-download.intel.com/akdlm/IRC_NAS/992857b9-624c-45de-9701-f6445d845359/l_BaseKit_p_2023.2.0.49397.sh \
    -o l_BaseKit_p_${INTEL_VERSION}.sh && \
    chmod +x l_BaseKit_p_${INTEL_VERSION}.sh && \
    ./l_BaseKit_p_${INTEL_VERSION}.sh -a -s --eula accept --components intel.oneapi.lin.mkl.devel:intel.oneapi.lin.vtune

# install Spack
ARG SPACK_VERSION=0.23.1
ARG SPACK_ROOT=/opt/spack
WORKDIR /opt/pkgs/spack
COPY docker_build/setup_spack.sh /opt/pkgs/spack/setup_spack.sh
RUN curl -L https://github.com/spack/spack/releases/download/v${SPACK_VERSION}/spack-${SPACK_VERSION}.tar.gz -o  spack-${SPACK_VERSION}.tar.gz && \
    mkdir -p /opt/spack && \
    tar -C /opt/spack -xzf spack-${SPACK_VERSION}.tar.gz --strip-component=1 && \
    ln -s /opt/spack/share/spack/spack-completion.bash /etc/bash_completion.d/spack-completion.bash && \
    bash /opt/pkgs/spack/setup_spack.sh ${SPACK_VERSION} && \
    . /opt/spack/share/spack/setup-env.sh && \
    spack clean --all

# setup files
WORKDIR /root
COPY docker_file/opt/modulefiles/ /opt/modulefiles/
COPY docker_file/opt/tools/ /opt/tools/
COPY docker_file/root/ /root/
COPY docker_build/bashrc_mod ./
RUN ls /root && chmod 744 /root/create_user.sh && \
    cat bashrc_mod >> /etc/skel/.bashrc && \
    cat bashrc_mod >> /root/.bashrc && \
    rm -f bashrc_mod

# Set up locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENTRYPOINT ["bash", "-c"]
