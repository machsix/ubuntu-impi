#!/bin/bash
set -e
major_ver="1.12"
minor_ver="1"
version=${major_ver}.${minor_ver}

root_dir=/opt
pkgbase=hdf5
install_dir=${root_dir}/${pkgbase}/${version}
source_dir=${root_dir}/${pkgbase}/${version}_source
symlink_dir=${root_dir}/${pkgbase}/latest
tarfile=${pkgbase}-${version}.tar.gz

. /etc/profile

rm -rf ${source_dir} ${install_dir} ${tarfile_dir}
mkdir -p ${source_dir}
mkdir -p ${install_dir}

wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${major_ver}/hdf5-${version}/src/hdf5-${version}.tar.gz -O ${tarfile}

tar xf ${tarfile} --strip-components=1 -C ${source_dir}

rm ${tarfile}

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

make -j
make install


cd ${root_dir}/${pkgbase}
ln -sf ${version} latest
cd -

cat > /etc/profile.d/07-hdf5.sh <<EOF
export HDF5_ROOT=${symlink_dir}
EOF
chmod 644 /etc/profile.d/07-hdf5.sh

install -dm 755 /etc/ld.so.conf.d
echo ${symlink_dir}/lib > /etc/ld.so.conf.d/hdf5.conf

cat > /usr/share/pkgconfig/hdf5.pc <<EOF
prefix=${symlink_dir}
exec_prefix=\${prefix}
includedir=\${prefix}/include
libdir=\${prefix}/lib
ccompiler=mpiicc
cxxcompiler=mpiicpc
fcompiler=mpiifort

Name: HDF5
Description: HDF5 Library
Version: ${version}
Cflags:   -I\${includedir}
Libs: -L\${libdir} -lhdf5 -lhdf5_fortran -lhdf5_cpp -lhdf5_hl
EOF

chmod 644 /usr/share/pkgconfig/hdf5.pc
ldconfig
rm -rf ${source_dir}

