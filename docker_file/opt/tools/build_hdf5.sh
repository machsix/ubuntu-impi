#!/bin/bash
set -e
pkgbase=hdf5
major_ver="1.12"
minor_ver="3"
version=${major_ver}.${minor_ver}

test_mode=0
if [ "$1" = "-t" ]; then
  test_mode=1
  echo "=== Test mode ==="
fi

current_dir=$(pwd)

# export APPLICATION_ROOT=${APPLICATION_ROOT:-${HOME}/sw/applications}
export APPLICATION_ROOT=${APPLICATION_ROOT:-/opt}
root_dir=${APPLICATION_ROOT}
if [ $test_mode -eq 1 ]; then
  root_dir=${current_dir}
fi

pkg_dir=${root_dir}/pkgs
tarfile=${pkg_dir}/${pkgbase}-${version}.tar.gz

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
  curl -kL https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${major_ver}/hdf5-${version}/src/hdf5-${version}.tar.gz -o ${tarfile}
else
  echo "Found downloaded package"
fi

#
echo "Extract the package to ${source_dir}"
tar xf ${tarfile} --strip-components=2 -C ${source_dir}

cd ${source_dir}
CC=mpiicc FC=mpiifort CXX=mpiicpc ./configure --prefix=${install_dir} \
  --enable-build-mode=production \
  --enable-fortran \
  --enable-cxx \
  --enable-hl \
  --enable-unsupported \
  --with-pic \
  --enable-parallel \
  --with-default-api-version=v110
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

cat > ${module_file} <<EOF
#%Module -*- tcl -*-
##
## modulefile
##
proc ModulesHelp { } {

  puts stderr "Adds HDF5/${version} to your environment variables,"
}

module-whatis "adds HDF5 to your environment variables"

set              version              ${version}
set              root                 ${install_dir}
prepend-path     PATH                 \$root/bin
prepend-path     LD_LIBRARY_PATH      \$root/lib
setenv           HDF5_ROOT            \$root
setenv           HDF5DIR              \$root/lib
setenv           HDF5INCLUDE          \$root/include
setenv           HDF5LIB              hdf5
EOF
