#!/bin/bash
set -e
pkgbase=petsc
major_ver="3.19"
minor_ver="5"
version=${major_ver}.${minor_ver}
hypre_version='2.24.0'
export PETSC_ARCH=arch-intel-opt-mumps-hypre

test_mode=0
if [ "$1" = "-t" ]; then
  test_mode=1
  echo "=== Test mode ==="
fi

current_dir=$(pwd)

export APPLICATION_ROOT=${APPLICATION_ROOT:-${HOME}/sw/applications}
root_dir=${APPLICATION_ROOT}
if [ $test_mode -eq 1 ]; then
  root_dir=${current_dir}
fi

pkg_dir=${root_dir}/pkgs
tarfile=${pkg_dir}/${pkgbase}-v${version}.tar.gz
external_package=${pkg_dir}/petsc_external

module_root=${root_dir}/modulefiles
module_dir=${module_root}/${pkgbase}
program_dir=${root_dir}/${pkgbase}
install_dir=${program_dir}/${version}
source_dir=${program_dir}/${version}_source
symlink_dir=${program_dir}/latest
module_file=${module_dir}/${version}

echo
echo " ======================================= "
echo "${pkgbase} application root: ${root_dir}"
echo "${pkgbase} installation directory: ${install_dir}"
echo "${pkgbase} src package: ${tarfile}"
echo "${pkgbase} build/src directory: ${source_dir}"
echo "${pkgbase} module_file: ${module_file}"
echo "${pkgbase} petsc external package: ${external_package}"
read -p "Continue? (Y/n)" key
if [ "${key}" = "n" ]; then
  cd ${current_dir}
  exit 0
fi

#. /etc/profile

rm -rf ${source_dir} ${install_dir}
mkdir -p ${module_dir}
mkdir -p ${program_dir}
mkdir -p ${install_dir}
mkdir -p ${source_dir}
mkdir -p ${external_package}
mkdir -p ${pkg_dir}

if [ ! -f ${tarfile} ]; then
  echo "Downloading the package ..."
  curl -kL https://gitlab.com/petsc/petsc/-/archive/v${version}/petsc-v${version}.tar.gz -o ${tarfile}
else
  echo "Found downloaded package"
fi

#
echo "Extract the package to ${source_dir}"
tar xf ${tarfile} --strip-components=1 -C ${source_dir}

cd ${source_dir}
export OPTFLAGS='-Ofast -DNDEBUG'
export INTEL_FLAGS='-diag-disable=10441'
./configure --prefix=${install_dir} \
            --with-debugging=0 \
            --with-packages-download-dir=${external_package} \
            --with-cc=mpiicc \
            --with-cxx=mpiicpc \
            --with-fc=mpiifort \
            --with-mpi=1 \
            --with-blaslapack-dir=${MKLROOT} \
            --with-avx512-kernels=1 \
            --with-pic=1 \
            --with-valgrind=0 \
            --with-hypre=1 \
            --with-clean --with-ssl=0 \
            --download-hypre="https://github.com/hypre-space/hypre/archive/refs/tags/v${hypre_version}.tar.gz" \
            --download-mumps \
            --with-blas-lapack-dir=${MKLROOT} \
            --with-scalapack-lib="-L${MKLROOT}/lib/intel64 -lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64" \
            --with-scalapack-include=${MKLROOT}/include \
            --download-sowing="${external_package}/v1.1.26-p7.tar.gz" \
            --CPPFLAGS="$INTEL_FLAGS" \
            --CXXPPFLAGS="$INTEL_FLAGS" \
            --CFLAGS="$INTEL_FLAGS" \
            --CXXFLAGS="$INTEL_FLAGS" \
            --COPTFLAGS="$OPTFLAGS" \
            --CXXOPTFLAGS="$OPTFLAGS" \
            --FOPTFLAGS="$OPTFLAGS"
            # --with-clanguage=${LANGUAGE:-C} \
            # --with-64-bit-indices=${INT64:-0} \
            # --with-scalar-type=${SCALAR:-real} \
            # --with-precision=${PRECISION:-double} \
#
#
#
echo
echo " ======================================= "
echo "Finish configuration"
read -p "Compile? (Y/n)" key

if [ "${key}" = "n" ]; then
  cd ${current_dir}
  exit 0
fi
make PETSC_DIR=${source_dir} PETSC_ARCH=${PETSC_ARCH} all
make install
#
#
#
echo
echo " ======================================= "
echo "Create symlink ${install_dir} => ${symlink_dir}"
ln -rsf ${install_dir} ${symlink_dir}
cd ${current_dir}
#
#
#
echo
echo " ======================================= "
echo "Create module file ${module_file}"

cat > ${module_file} <<EOF
#%Module -*- tcl -*-
##
## modulefile
##
proc ModulesHelp { } {

  puts stderr "Adds PETSc (${version}) AVX(2,512) optimized to your environment,"
}

set             root             ${install_dir}
prepend-path    LD_LIBRARY_PATH  \$root/lib
setenv          PETSC_DIR        \$root
setenv          PETSC_ARCH       ${PETSC_ARCH}
EOF
