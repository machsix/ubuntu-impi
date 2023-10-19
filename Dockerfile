FROM intel/oneapi-hpckit:2023.2.1-devel-ubuntu22.04
LABEL org.opencontainers.image.authors="28209092+machsix@users.noreply.github.com>"
ARG LLVM_VERSION=17

# fix intel key
RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
	| gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
	| tee /etc/apt/sources.list.d/oneAPI.list
RUN wget -O- https://apt.kitware.com/keys/kitware-archive-latest.asc 2> /dev/null \
	| gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' \
	| tee /etc/apt/sources.list.d/kitware.list >/dev/null

# install fundamental packages
RUN echo 'APT::Acquire::Retries "10";' > /etc/apt/apt.conf.d/80-retries
RUN apt-get update && apt-get install -y apt-transport-https kitware-archive-keyring
RUN rm /usr/share/keyrings/kitware-archive-keyring.gpg
RUN apt-get update && \
	apt-get upgrade -y && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o=Dpkg::Use-Pty=0 \
	cmake \
	wget \
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
	software-properties-common && \
	rm -rf /var/lib/apt/lists/*

# install git + vim + python
RUN apt-add-repository ppa:git-core/ppa && \
	apt-add-repository ppa:deadsnakes/ppa && \
	apt-add-repository ppa:jonathonf/vim && \
	apt-get update && \
	apt-get upgrade -y && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o=Dpkg::Use-Pty=0 \
	vim \
	git \
	python3.10 \
	python3-pip \
	python3-pynvim \
	python3-distutils \
	python3-lib2to3 && \
	rm -rf /var/lib/apt/lists/* && \
	ln -sf $(which python3.10) /usr/local/bin/python

# install nvdia cuda toolkit
RUN apt-key del 7fa2af80 && \
	wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb && \
	dpkg -i cuda-keyring_1.1-1_all.deb && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o=Dpkg::Use-Pty=0 -y cuda && \
	rm -rf /var/lib/apt/lists/* && \
	rm -f cuda-keyring_1.1-1_all.deb

# install llvm
RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
	./llvm.sh ${LLVM_VERSION} &&\
	rm -rf /var/lib/apt/lists/* && \
	rm -f llvm.sh

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

# set clang env
COPY docker_build/set-clang.sh .
RUN bash ./set-clang.sh && \
	rm -f set-clang.sh

COPY docker_file/ /
RUN chmod 644 /etc/profile.d/05-intel-compiler.sh && \
	chmod 744 /opt/tools/*.sh && \
	chmod 744 /root/create_user.sh

# modify bashrc
COPY docker_build/bashrc_mod ./
RUN cat bashrc_mod >> /etc/skel/.bashrc && \
	cat bashrc_mod >> /root/.bashrc && \
	rm -f bashrc_mod

ENTRYPOINT ["bash", "-c"]
