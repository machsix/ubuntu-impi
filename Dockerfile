FROM ubuntu:latest
LABEL org.opencontainers.image.authors="28209092+machsix@users.noreply.github.com>"

ARG url=https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
ARG repo=https://apt.repos.intel.com/oneapi
ARG disable_cert_check=

RUN if [ "$disable_cert_check" ] ; then echo "Acquire::https::Verify-Peer \"false\";\nAcquire::https::Verify-Host \"false\";" > /etc/apt/apt.conf.d/99-disable-cert-check ; fi
RUN echo 'APT::Acquire::Retries "10";' > /etc/apt/apt.conf.d/80-retries
RUN apt-get update -y && \
	apt-get install -y --no-install-recommends -o=Dpkg::Use-Pty=0 \
	wget \
	gnupg \
	openssl \
	openssh-client \
	ca-certificates && \
	rm -rf /var/lib/apt/lists/* && \
        wget $url && \
	file=$(basename "$url") && \
	apt-key add "$file" && \
	rm "$file" && \
	echo "deb $repo all main" > /etc/apt/sources.list.d/oneAPI.list

# install fundamental packages + llvm + intel-mpi
RUN apt-get update -y && \
	apt-get install -y --no-install-recommends -o=Dpkg::Use-Pty=0 \
	build-essential \
	gfortran \
	pkg-config \
	locales \
	libarchive13 \
	wget \
	zsh \
        pkg-config \
	curl \
        iputils-ping \
        rsync \
        openssh-client \
	fontconfig \
	cmake \
	vim \
	doxygen \
	graphviz \
	tmux \
	git \
	llvm-11 \
	clang-11 \
	clang-tools-11 \
	clangd-11 \
        clang-format-11 \
	sudo \
	python3-pip \
	python3-pynvim \
	python3-distutils \
        python3-lib2to3 \
        iproute2 \
	intel-basekit-getting-started \
	intel-hpckit-getting-started \
	intel-oneapi-advisor \
	intel-oneapi-common-licensing \
	intel-oneapi-common-vars \
	intel-oneapi-compiler-dpcpp-cpp \
	intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic \
	intel-oneapi-compiler-fortran \
	intel-oneapi-dev-utilities \
	intel-oneapi-inspector \
	intel-oneapi-ipp-devel \
	intel-oneapi-ippcp-devel \
	intel-oneapi-itac \
	intel-oneapi-mkl-devel \
	intel-oneapi-mpi-devel \
	intel-oneapi-openmp \
	intel-oneapi-tbb-devel \
	intel-oneapi-vtune &&\
	rm -rf /var/lib/apt/lists/* && \
	ln -sf $(which python3) /usr/local/bin/python

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8
    
COPY docker_build/set-clang.sh .
RUN bash ./set-clang.sh && \
	rm -f set-clang.sh

COPY docker_file/ /
RUN chmod 644 /etc/profile.d/05-intel-compiler.sh && \
	chmod 744 /opt/tools/*.sh && \
	chmod 744 /root/create_user.sh

# build and install PETSc
RUN bash /opt/tools/build_petsc_impi_2019.sh

# build and install HDF5
RUN bash /opt/tools/build_hdf5.sh

# install Distrod
RUN curl -L -O "https://raw.githubusercontent.com/nullpo-head/wsl-distrod/main/install.sh" && \
    chmod +x install.sh && \
    ./install.sh install && \
    mv install.sh /opt/tools/install_distrod.sh

# modify bashrc
COPY docker_build/bashrc_mod ./
RUN cat bashrc_mod >> /etc/skel/.bashrc && \
	cat bashrc_mod >> /root/.bashrc && \
	rm -f bashrc_mod

ENTRYPOINT ["bash", "-c"]
