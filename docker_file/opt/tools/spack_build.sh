#!/bin/bash
SPACK_VERSION=${1:-0.23.1}
source /opt/spack/share/spack/setup-env.sh

spack mirror add "v${SPACK_VERSION}}" https://binaries.spack.io/v${SPACK_VERSION}
spack buildcache keys --install --trust

echo "Build HDF5 1.12.3 with Intel MPI and Fortran support..."
spack install --no-cache -v hdf5@1.12.3%intel@2021.10.0 +fortran+hl+mpi api=v110 ^intel-oneapi-mpi ++classic-names
# spack install --cache-only  hdf5@1.12.3 +fortran+hl+mpi arch=linux-ubuntu22.04-x86_64_v3

echo "Installing cmake"
spack install --cache-only cmake@3.30.5%gcc

echo "Installing LLVM"
spack install -v llvm@16.0.6%intel@2021.10.0 +clang +compiler-rt +lld +lldb +libcxx +libunwind +openmp api=v110