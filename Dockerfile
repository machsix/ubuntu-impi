FROM intel/oneapi-hpckit:2023.2.1-devel-ubuntu22.04
LABEL org.opencontainers.image.authors="28209092+machsix@users.noreply.github.com>"
ARG LLVM_VERSION=17
ARG PYTHON_VERSION=3.12
ARG INTEL_VERSION=2023.2.1
ARG CUDA_TOOLKIT=cuda-toolkit-12-4
# Fix keys
RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
    | tee /etc/apt/sources.list.d/oneAPI.list && \
    wget -O- https://apt.kitware.com/keys/kitware-archive-latest.asc 2> /dev/null \
    | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
    wget -O- https://apt.kitware.com/kitware-archive.sh 2> /dev/null | DEBIAN_FRONTEND=noninteractive bash

RUN mkdir -p /etc/apt/preferences.d
COPY docker_build/intel_pref /etc/apt/preferences.d/

# install fundamental packages
RUN echo 'APT::Acquire::Retries "10";' > /etc/apt/apt.conf.d/80-retries && \
    apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https software-properties-common && \
    apt-add-repository ppa:git-core/ppa && \
    apt-add-repository ppa:deadsnakes/ppa && \
    apt-add-repository ppa:jonathonf/vim && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o=Dpkg::Use-Pty=0 \
    gnupg \
    openssl \
    openssh-client \
    build-essential \
    gfortran \
    pkg-config \
    locales \
    libarchive13 \
    zsh \
    pkg-config \
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
    binfmt-support \
    vim \
    git \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv \
    python${PYTHON_VERSION}-distutils \
    python3-pip \
    python${PYTHON_VERSION}-lib2to3 \
    cmake && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -sf $(which python${PYTHON_VERSION}) /usr/local/bin/python

# install nvdia cuda toolkit
RUN apt-key del 7fa2af80 && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o=Dpkg::Use-Pty=0 -y ${CUDA_TOOLKIT} && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f cuda-keyring_1.1-1_all.deb

# install llvm
COPY docker_build/set_clang.sh ./
RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh ${LLVM_VERSION} &&\
    rm -rf /var/lib/apt/lists/* && \
    rm -f llvm.sh && \
    bash set_clang.sh && \
    rm -rf set_clang.sh

# setup wsl
COPY docker_build/set_wsl.sh ./
RUN bash set_wsl.sh && \
    rm -rf set_wsl.sh

# install lua
RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o=Dpkg::Use-Pty=0 \
    lua5.1 tcl-dev lua5.1-bitop liblua5.1-0-dev lua5.1-json lua5.1-lpeg-dev lua5.1-posix-dev lua5.1-term && \
    rm -rf /var/lib/apt/lists/* && \
    wget -qO- https://sourceforge.net/projects/lmod/files/Lmod-8.7.tar.bz2/download | tar xj && \
    cd Lmod-8.7 && \
    ./configure --prefix=/opt && \
    make install && \
    cd .. && rm -rf Lmod-8.7 && \
    ln -s /opt/lmod/lmod/init/profile        /etc/profile.d/z00_lmod.sh && \
    ln -s /opt/lmod/lmod/init/cshrc          /etc/profile.d/z00_lmod.csh

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8

# recover env set by intel's docker
ENV LANG=en_US.UTF-8
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV PKG_CONFIG_PATH=
ENV LD_LIBRARY_PATH=
ENV LIBRARY_PATH=
ENV MANPATH=

# copy my tools
COPY docker_file/ /
RUN chmod 644 /etc/profile.d/zzz_05-intel-compiler.sh && \
    chmod 744 /opt/tools/*.sh && \
    chmod 744 /root/create_user.sh

# modify bashrc
COPY docker_build/bashrc_mod ./
RUN cat bashrc_mod >> /etc/skel/.bashrc && \
    cat bashrc_mod >> /root/.bashrc && \
    rm -f bashrc_mod

ENTRYPOINT ["bash", "-c"]
