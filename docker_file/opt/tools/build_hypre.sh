#!/bin/bash
set -e
pkgbase=hypre
major_ver="2.32"
minor_ver="0"
version=${major_ver}.${minor_ver}
gpu_build=0
test_mode=0
lua_module=1
toolchain=nvhpc
toolchain=intel
# toolchain=PrgEnv-cray
# toolchain=PrgEnv-nvidia
if [ "$1" = "-t" ]; then
  test_mode=1
  echo "=== Test mode ==="
fi

current_dir=$(pwd)
root_dir=/opt
if [ $test_mode -eq 1 ]; then
  root_dir=${current_dir}
fi

pkg_dir=${root_dir}/pkgs
tarfile=${pkg_dir}/${pkgbase}-${version}.tar.gz

module_root=${root_dir}/modulefiles
module_dir=${module_root}/${pkgbase}/${toolchain}
program_dir=${root_dir}/${pkgbase}/${toolchain}

install_dir=${program_dir}/${version}
module_file=${module_dir}/${version}.tcl
if [ $lua_module -eq 1 ]; then
  module_file=${module_dir}/${version}.lua
fi
source_dir=${program_dir}/${version}_source
symlink_dir=${program_dir}/latest

echo
echo " ======================================= "
echo "${pkgbase} application root: ${root_dir}"
echo "${pkgbase} installation directory: ${install_dir}"
echo "${pkgbase} src package: ${tarfile}"
echo "${pkgbase} build/src directory: ${source_dir}"
echo "${pkgbase} module_file: ${module_file}"
echo " ======================================= "
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
mkdir -p ${pkg_dir}


if [ ! -f ${tarfile} ]; then
  echo "Downloading the package ..."
  curl -kL https://github.com/hypre-space/hypre/archive/refs/tags/v${version}.tar.gz -o ${tarfile}
else
  echo "Found downloaded package"
fi

#
echo "Extract the package to ${source_dir}"
tar xf ${tarfile} --strip-components=1 -C ${source_dir}

#=== For NERSC ===
# module swap PrgEnv-gnu $toolchain
# module load cray-mpich
module load $toolchain
cd ${source_dir}/src
# if [ $gpu_build -eq 1 ]; then
#   CC=cc CXX=CC FC=ftn HYPRE_CUDA_SM=80 ./configure --prefix=${install_dir} --with-cuda
# else
#   CC=cc CXX=CC FC=ftn ./configure --prefix=${install_dir}
# fi
if [ $toolchain = "intel" ]; then
  CC=mpiicc CXX=mpiicpc FC=mpiifort ./configure --prefix=${install_dir}
else
  CC=mpicc CXX=mpic++ FC=mpifort ./configure --prefix=${install_dir}
fi
# CC=gcc CXX=g++ FC=gfortran ./configure --prefix=${install_dir}


echo
echo " ======================================= "
echo "Finish configuration"
read -p "Compile? (Y/n)" key

if [ "${key}" = "n" ]; then
  cd ${current_dir}
  exit 0
fi
make -j
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

if [ $lua_module -eq 0 ]; then
cat > ${module_file} <<EOF
#%Module -*- tcl -*-
##
## modulefile
##
proc ModulesHelp { } {

  puts stderr "Adds ${pkgbase}/${version} to your environment variables,"
}

module-whatis "adds ${pkgbase} to your environment variables"

module           load                 ${toolchain}
set              version              ${version}
set              root                 ${install_dir}
prepend-path     LD_LIBRARY_PATH      \$root/lib
prepend-path     HYPRE                \$root
EOF
else
cat > ${module_file} <<EOF
help([[
Adds ${pkgbase}/${version} to your environment variables.
]])

whatis("Adds ${pkgbase} to your environment variables")

load("${toolchain}")

local version = "${version}"
local root = "${install_dir}"

prepend_path("LD_LIBRARY_PATH", pathJoin(root, "lib"))
setenv("HYPRE", root)
EOF

fi
