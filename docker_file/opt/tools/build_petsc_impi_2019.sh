#!/bin/bash
set -e
# set -x

root_dir=/opt
pkgbase=petsc
petsc_version='3.15.5'
hypre_version='2.20.0'
install_dir=${root_dir}/${pkgbase}/${petsc_version}
symlink_dir=${root_dir}/${pkgbase}/latest
source_dir=${root_dir}/${pkgbase}/${petsc_version}_source
tarfile=${pkgbase}-v${petsc_version}.tar.gz

export PETSC_ARCH=arch-linux-c-opt

. /etc/profile

rm -rf ${source_dir} ${install_dir} ${tarfile_dir}
mkdir -p ${source_dir}
mkdir -p ${install_dir}

wget https://gitlab.com/petsc/petsc/-/archive/v${petsc_version}/petsc-v${petsc_version}.tar.gz -O ${tarfile}

tar xf ${tarfile} --strip-components=1 -C ${source_dir}

rm ${tarfile}

cd ${source_dir}

export OPTFLAGS='-O3'
./configure --prefix=${install_dir} \
            --with-cc=mpiicc \
            --with-cxx=mpiicpc \
            --with-fc=mpiifort \
            --with-clanguage=${LANGUAGE:-C} \
            --with-64-bit-indices=${INT64:-0} \
            --with-scalar-type=${SCALAR:-real} \
            --with-precision=${PRECISION:-double} \
            --with-mpi=1 \
            --with-blaslapack-dir=${MKLROOT} \
            --with-avx512-kernels=1 \
            --with-pic=1 \
            --with-valgrind=0 \
            --with-hypre=1 \
            --download-hypre="https://github.com/hypre-space/hypre/archive/refs/tags/v${hypre_version}.tar.gz" \
            --COPTFLAGS="$OPTFLAGS" \
            --CXXOPTFLAGS="$OPTFLAGS" \
            --FOPTFLAGS="$OPTFLAGS"
make PETSC_DIR=${source_dir} PETSC_ARCH=${PETSC_ARCH} all
make install

cd ${root_dir}/${pkgbase}
ln -sf ${petsc_version} latest
cd -

cat > /etc/profile.d/06-petsc.sh <<EOF
export PETSC_DIR=${symlink_dir}
export PETSC_ARCH=${PETSC_ARCH}
EOF
chmod 644 /etc/profile.d/06-petsc.sh

install -dm 755 /etc/ld.so.conf.d
echo ${symlink_dir}/lib > /etc/ld.so.conf.d/petsc.conf
ln -sf ${symlink_dir}/lib/pkgconfig/PETSc.pc /usr/share/pkgconfig/PETSc.pc
ldconfig

rm -rf ${source_dir}
