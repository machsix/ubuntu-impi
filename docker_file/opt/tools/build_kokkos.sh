#!/usr/bin/env bash
export CUDA_ARCH="AMPERE86" # 30 series
#export CUDA_ARCH="TURING75" # T1000
export kokkos_version="4.1.00"
export CXX=icpc
export CXXFLAGS=
export CUDA_HOME=${CUDA_HOME:-/usr/local/cuda}
export PATH=${CUDA_HOME}/bin:${PATH}

kokkos_src_folder=${HOME}/kokkos
kokkos_root_folder=/opt/kokkos
kokkos_install_folder=${kokkos_root_folder}/${kokkos_version}_${CUDA_ARCH}
kokkos_build_folder=${kokkos_root_folder}/${kokkos_version}_build

rm -rf ${kokkos_src_folder}
git clone https://github.com/kokkos/kokkos ${kokkos_src_folder}
cd $kokkos_src_folder
git checkout ${kokkos_version}

rm -rf ${kokkos_install_folder} ${kokkos_build_folder}
mkdir -p ${kokkos_install_folder} ${kokkos_build_folder}

cd ${kokkos_build_folder}
cmake ${kokkos_src_folder} \
 -DCMAKE_CXX_COMPILER=${CXX} \
 -DCMAKE_INSTALL_PREFIX=${kokkos_install_folder} \
 -DKokkos_ENABLE_OPENMP=ON \
 -DKokkos_ENABLE_CUDA=ON \
 -DKokkos_ENABLE_SERIAL=ON \
 -DKokkos_CUDA_DIR=${CUDA_HOME} \
 -DKokkos_ARCH_${CUDA_ARCH}=ON
make -j
make install
rm -rf ${kokkos_build_folder}
cat > /opt/modulefiles/Core/kokkos/${kokkos_version}_${CUDA_ARCH} <<EOF
#%Module1.0#####################################################################
##
## Kokkos ${kokkos_version}_${CUDA_ARCH} modulefile
##
proc ModulesHelp { } {
        global version modroot

        puts stdout "\t loads Kokkos \$version \n"
}

module-whatis   "loads Kokkos ${kokkos_version}_${CUDA_ARCH}"

# for Tcl script use only
set     version          ${kokkos_version}
set     root             ${kokkos_install_folder}
setenv  KOKKOS_PATH      \$root
setenv  KOKKOS_PREFIX    \$root
append-path    PATH      \$root/bin
EOF
