FROM intel/oneapi-hpckit:2023.1.0-devel-ubuntu22.04
LABEL org.opencontainers.image.authors="28209092+machsix@users.noreply.github.com>"
ARG LLVM_VERSION=17

# fix intel key
RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
    tee /etc/apt/trusted.gpg.d/oneapi-archive-keyring.asc > /dev/null && \
    wget -qO - https://repositories.intel.com/graphics/intel-graphics.key | \
    tee /etc/apt/trusted.gpg.d/intel-graphics.asc > /dev/null

# install fundamental packages
RUN echo 'APT::Acquire::Retries "10";' > /etc/apt/apt.conf.d/80-retries
RUN apt-get update && \
	apt-get upgrade -y && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o=Dpkg::Use-Pty=0 \
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
