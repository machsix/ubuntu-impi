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
    lua5.1 lua5.1-bitop liblua5.1-0-dev lua5.1-json lua5.1-lpeg-dev lua5.1-posix-dev lua5.1-term \
    tcl-dev tree bc file patchelf \
    vim-nox \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda from conda-forge
ARG CONDA_INSTALL_DIR=/opt/python/miniforge3
WORKDIR /opt/pkgs/miniforge3
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh && \
    bash miniconda.sh -b -p ${CONDA_INSTALL_DIR} && \
    echo "blas=*=mkl" >> ${CONDA_INSTALL_DIR}/conda-meta/pinned && \
    ${CONDA_INSTALL_DIR}/bin/conda config --system --add channels conda-forge && \
    ${CONDA_INSTALL_DIR}/bin/conda config --system --set channel_priority strict


# install lmod
ARG LMOD_VERSION=8.7.60
WORKDIR /opt/pkgs
RUN curl -L https://github.com/TACC/Lmod/archive/refs/tags/${LMOD_VERSION}.tar.gz -o Lmod-${LMOD_VERSION}.tar.gz && \
    mkdir -p /opt/pkgs/lmod && \
    tar -C /opt/pkgs/lmod -xzf Lmod-${LMOD_VERSION}.tar.gz --strip-component=1 && \
    cd /opt/pkgs/lmod && \
    ./configure --prefix=/opt && \
    make install && \
    ln -s /opt/lmod/lmod/init/profile        /etc/profile.d/z00_lmod.sh && \
    ln -s /opt/lmod/lmod/init/cshrc          /etc/profile.d/z00_lmod.csh && \
    echo 'MODULEPATH=/opt/spack/share/spack/lmod/linux-debian12-x86_64:${MODULEPATH}' >> /etc/profile.d/z00_lmod.sh && \
    . /etc/profile.d/z00_lmod.sh


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
    ./l_BaseKit_p_${INTEL_VERSION}.sh -a -s --eula accept --components intel.oneapi.lin.mkl.devel:intel.oneapi.lin.vtune && \
    . /opt/intel/oneapi/setvars.sh

# install Spack
ARG SPACK_VERSION=0.23.1
WORKDIR /opt/pkgs/spack
RUN curl -L https://github.com/spack/spack/releases/download/v${SPACK_VERSION}/spack-${SPACK_VERSION}.tar.gz -o  spack-${SPACK_VERSION}.tar.gz && \
    mkdir -p /opt/spack && \
    tar -C /opt/spack -xzf spack-${SPACK_VERSION}.tar.gz --strip-component=1 && \
    ln -s /opt/spack/share/spack/spack-completion.bash /etc/bash_completion.d/spack-completion.bash && \
    mkdir -p /etc/spack && \
    . /etc/profile.d/z00_lmod.sh && \
    . /opt/intel/oneapi/setvars.sh && \
    . /opt/spack/share/spack/setup-env.sh && \
    cp -a /opt/spack/etc/spack/defaults/config.yaml /etc/spack/config.yaml && \
    sed -i 's|^    root: .*|    root: /opt|' /etc/spack/config.yaml && \
    sed -i 's|^\([[:space:]]*all:\) "{architecture}\(.*"\)|\1 "spack_built\2|' /etc/spack/config.yaml && \
    ln -sf /etc/spack /root/.spack && \
    spack config add modules:default:enable:[lmod] && \
    echo 'export MODULEPATH=/opt/spack/share/spack/lmod/linux-ubuntu22.04-x86_64:${MODULEPATH}' >> /etc/profile.d/z00_lmod.sh && \
    spack compiler find && \
    spack external find && \
    echo "  intel-oneapi-mpi:" >> /etc/spack/packages.yaml && \
    echo "    externals:" >> /etc/spack/packages.yaml && \
    echo "    - spec: intel-oneapi-mpi@2021.10.0" >> /etc/spack/packages.yaml && \
    echo "      prefix: /opt/intel/oneapi" >> /etc/spack/packages.yaml && \
    echo "  intel-oneapi-mkl:" >> /etc/spack/packages.yaml && \
    echo "    externals:" >> /etc/spack/packages.yaml && \
    echo "    - spec: intel-oneapi-mkl@2023.2.0" >> /etc/spack/packages.yaml && \
    echo "      prefix: /opt/intel/oneapi/" >> /etc/spack/packages.yaml && \
    wget https://github.com/mikefarah/yq/releases/download/v4.45.4/yq_linux_amd64.tar.gz -O - |\
    tar xz && mv yq_linux_amd64 /usr/local/bin/yq && \
    yq -i '.compilers[0].compiler.environment = {"prepend_path": { "LD_LIBRARY_PATH": "/opt/intel/oneapi/compiler/2023.2.0/linux/compiler/lib/intel64", "LIBRARY_PATH": "/opt/intel/oneapi/compiler/2023.2.0/linux/compiler/lib/intel64" }    }' /root/.spack/linux/compilers.yaml && \
    spack -d install -v hdf5@1.12.3%intel@2021.10.0 +fortran+hl+mpi api=v110 ^intel-oneapi-mpi ++classic-names && \
    spack module lmod refresh --delete-tree -y && \
    spack clean --all

# setup files
COPY docker_file/opt/modulefiles /opt/modulefiles
COPY docker_file/opt/tools /opt/tools
COPY docker_file/root/ root/
COPY docker_build/bashrc_mod ./
RUN chmod 744 /root/create_user.sh && \
cat bashrc_mod >> /etc/skel/.bashrc && \
    cat bashrc_mod >> /root/.bashrc && \
    rm -f bashrc_mod

# Set up locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENTRYPOINT ["bash", "-c"]
