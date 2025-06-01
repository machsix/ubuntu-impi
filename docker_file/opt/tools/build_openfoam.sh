#!/bin/bash
set -e
umask 0002
pkgbase=openfoam
major_ver="2.3"
minor_ver="0"
version=${major_ver}.${minor_ver}
boost_version="1.54.0"
boost_altversion="$(echo ${boost_version} | sed 's/\./_/g')"

export TZ="America/Los_Angeles"

if [ ! -n "$GMP_LIBRARIES" ]; then
  echo '$GMP_LIBRARIES and $GMP_INCLUDE_DIR are not set'
  echo 'CGAL may not be compiled correctly, but the final OpenFOAM should work'
fi

nice_path () {
  echo "\$HOME/$(realpath -s --relative-to=$HOME ${1})"
}

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
mkdir -p $root_dir
root_dir_rel=$(nice_path $root_dir)
if [[ "${root_dir_rel}" == "/enc/"* ]] || [[ "${root_dir_rel}" == *"storage_"* ]]; then
  echo "Your set of \$APPLICATION_ROOT can lead of non-reusable binary"
  exit 1
fi

pkg_dir=${root_dir}/pkgs
tarfiles=(
  "${pkg_dir}/OpenFOAM-${version}.tgz"
  "${pkg_dir}/ThirdParty-${version}.tgz"
  "${pkg_dir}/boost_${boost_altversion}.tar.gz"
)
patch_file="${pkg_dir}/OpenFOAM-${version}-Intel.patch"
crtrs_foam="${pkg_dir}/rhoSimpleFoam_CRTRS.tar.gz"
module_root=${root_dir}/modulefiles
module_dir=${module_root}/${pkgbase}
#  /*  Never change ===================
export WM_PROJECT=OpenFOAM
export WM_PROJECT_VERSION=${version}
program_dir=${root_dir}/${WM_PROJECT}
buildlog_dir=${program_dir}/build_log
mkdir -p $program_dir
foamInstall="$(nice_path ${program_dir}/../)/\$WM_PROJECT"
projectDir="${program_dir}/OpenFOAM-$WM_PROJECT_VERSION"
crtrsProject="${program_dir}/rhoSimpleFoam_CRTRS-$WM_PROJECT_VERSION"
export WM_THIRD_PARTY_DIR="${program_dir}/ThirdParty-$WM_PROJECT_VERSION"
thirdPartyDir=${WM_THIRD_PARTY_DIR}
boostDir="${thirdPartyDir}/boost_${boost_altversion}"
download_links=(
  "https://sourceforge.net/projects/openfoam/files/${version}/OpenFOAM-${version}.tgz"
  "https://sourceforge.net/projects/openfoam/files/${version}/ThirdParty-${version}.tgz"
  "https://sourceforge.net/projects/boost/files/boost/${boost_version}/boost_${boost_altversion}.tar.gz"
)
final_dir=(
  "${projectDir}"
  "${thirdPartyDir}"
  "${boostDir}"
)
tar_args=(
  "--strip-components=1 -C ${final_dir[0]}"
  "--strip-components=1 -C ${final_dir[1]}"
  "--strip-components=1 -C ${final_dir[2]}"
)
#   ============= End of never change */
module_file=${module_dir}/${version}

mkdir -p ${module_dir}
mkdir -p ${program_dir}
mkdir -p ${projectDir} ${thirdPartyDir} ${boostDir}
mkdir -p ${pkg_dir}
mkdir -p ${crtrsProject}


echo
echo " ======================================= "
echo "APPLICATION_ROOT: $(nice_path $root_dir)"
echo "OpenFOAM: $(nice_path $projectDir)"
echo "ThirdParty: $(nice_path $thirdPartyDir)"
echo "Boost: $(nice_path $boostDir)"
echo "rhoSimpleFoam_CRTRS: $(nic_path $crtrsProject)"
echo "${pkgbase} src packages:"
printf ' - %s\n' "${tarfiles[@]}"
echo "${pkgbase} module_file: $(nice_path $module_file)"
read -p "Continue? (Y/n)" key
if [ "${key}" = "n" ]; then
  cd ${current_dir}
  exit 0
fi

for i in ${!tarfiles[@]}; do
  tarfile=${tarfiles[$i]}
  download_link=${download_links[$i]}
  if [ ! -f ${tarfile} ]; then
    echo "Downloading the package: $(basename ${tarfile})"
    curl -kL  ${download_link} -o ${tarfile}
  else
    echo "Found downloaded package: $(basename ${tarfile})"
  fi
done


# ===================================================
echo "Extract the packages"
echo "This will be slow due to the size of the packages"
for i in ${!tarfiles[@]}; do
  tarfile=${tarfiles[$i]}
  tarfile_size=$(du -h ${tarfile} | awk '{print $1}')
  file_size=`echo "scale=0; $(zcat ${tarfile} | wc --bytes)/1024/1024" | bc -l`
  echo " - ${tarfile##*/}: ${tarfile_size} => ${file_size} MB"
  test_file=${final_dir[$i]}/Allwmake
  if [ ${i} -eq 2 ]; then
    test_file=${final_dir[$i]}/bootstrap.sh
  fi
  j=1
  if [ -f "${test_file}" ]; then
    j=0
    read -p "Files already exist there, continue extracting? (N/y)" key
    if [ "$key" = 'y' ]; then
      j=1
    fi
  fi
  if [ "$j" -eq 1 ]; then
    tar xf ${tarfile} ${tar_args[$i]}
  fi
done
# ===================================================
# Patch
#FIXME
backup_orig () {
  for i in "$@"; do
    if [ ! -f ${i}.orig ]; then
      cp -a ${i} ${i}.orig
    fi
  done
}

backup_orig ${projectDir}/etc/config/CGAL.sh ${projectDir}/etc/config/CGAL.csh ${thirdPartyDir}/makeCGAL
backup_orig ${projectDir}/etc/bashrc ${projectDir}/etc/config/gperftools.sh

echo " ======= Applying patches ============="
echo "patching ${projectDir}/etc/config/CGAL.sh"
sed -i "s|boost-system|${boostDir##*/}|g" ${projectDir}/etc/config/CGAL.sh

echo "patching ${projectDir}/etc/config/CGAL.csh"
sed -i "s|boost-system|${boostDir##*/}|g" ${projectDir}/etc/config/CGAL.csh

echo "patching ${thirdPartyDir}/makeCGAL"
sed -i "s|boost-system|${boostDir##*/}|g" ${thirdPartyDir}/makeCGAL

echo "patching ${projectDir}/etc/config/gperftools.sh"
sed -i 's/version/gperftools_ver/g' ${projectDir}/etc/config/gperftools.sh


echo "patching ${projectDir}/etc/bashrc"
sed -i "s|^foamInstall=.*$|foamInstall=${foamInstall}|" ${projectDir}/etc/bashrc
sed -i 's|^export WM_COMPILER=.*$|export WM_COMPILER=Icc|' ${projectDir}/etc/bashrc
sed -i 's|^export WM_MPLIB=.*$|export WM_MPLIB=INTELMPI|' ${projectDir}/etc/bashrc

if [ ! -f "${patch_file}" ]; then
  echo "MPI patch is missing: ${patch_file}" 1>&2
  exit 1
fi
if grep -q "HAN's PATCH" ${projectDir}/etc/config/settings.sh; then
  echo "MPI patch was already patched"
else
  patch -b -p1 -d ${projectDir}/ < ${patch_file}
fi

# patch created with diff -Naru

echo " ======================================= "
echo "Finish configuration. Start compiling."
echo "This will take extensive time. Make sure you're in a screen/tmux session"
echo "Otherwise, broken ssh connection may lead to failure"

if [ "${TERM:0:6}" != "screen" ] && [ ! -n "$TMUX" ];  then
  echo "**ERROR** You are not in either screen or tmux **ERROR**"
  exit 1
fi

#NCPU=$(grep '^core id' /proc/cpuinfo |sort -u|wc -l)
NCPU=$(echo "scale=0; $(nproc --all)/2" |bc -l)

skip_build=0
read -p "Skip building with all ${NCPU} CPUs? (N/y) " key
if [ "${key}" = "y" ]; then
  skip_build=1
fi

unset WM_PROJECT
unset WM_PROJECT_VERSION
unset WM_THIRD_PARTY_DIR

source ${projectDir}/etc/bashrc
export WM_NCOMPPROCS=${NCPU}

if [ "${WM_PROJECT_DIR}" != "${projectDir}" ]; then
  echo "something is wrong"
  exit 1
fi

cd $WM_PROJECT_DIR
log_prefix=$(date +"%Y%m%d-%H%M")
mkdir -p $buildlog_dir
error_log="${buildlog_dir}/build_v${version}_stderr_${log_prefix}.log"
build_log="${buildlog_dir}/build_v${version}_${log_prefix}.log"
test_log="${buildlog_dir}/build_v${version}_test_${log_prefix}.log"

if [ "$skip_build" -eq 0 ]; then
  time_start_build=$(date +%s)
  ./Allwmake 1> >(tee ${build_log} ) 2> >(tee ${error_log} >&2 )
  time_end_build=$(date +%s)
  cat >> ${build_log} <<EOF

Start build at: $(date -d @${time_start_build})
End build at: $(date -d @${time_end_build})
Took $(echo "scale=0; (${time_end_build}-${time_start_build})/60" | bc -l) min

EOF
fi
cd $current_dir

#
#
echo
echo " ======================================= "
read -p "Run testing? (N/y)" key
if [ "$key" == 'y' ]; then
  . ${projectDir}/bin/foamInstallationTest 2>&1 | tee ${test_log}
fi

#
#
echo
echo " ======================================= "
read -p "Compiling rhoSimpleFoam_CRTRS? (Y/n)" key
if [ "$key" != 'n' ]; then
  if [ -d "${crtrsProject}/Make" ]; then
    echo "Dir ${crtrsProject} will be recreated"
    rm -rf $crtrsProject
    mkdir -p $crtrsProject
  fi
  tar xf $crtrs_foam --strip-components=1 -C $crtrsProject

  cd $crtrsProject
  wmake libo
  cp -a librhoSimpleFoam_CRTRS.o rhoSimpleFoam_CRTRS_rescale.obj
  echo "Final binary file: $(nice_path $crtrsProject)/rhoSimpleFoam_CRTRS_rescale.obj"
  size rhoSimpleFoam_CRTRS_rescale.obj
  md5sum rhoSimpleFoam_CRTRS_rescale.obj > rhoSimpleFoam_CRTRS_rescale.obj.md5
  cd $current_dir
fi


#
#
echo
echo " ======================================= "
echo "Create module file ${module_file}"

mpi_ldpath=""
mpi_binpath=""

if [ -d "$MPI_ARCH_PATH" ]
then
  if [ -d "$MPI_ARCH_PATH"/intel64/bin ] \
  && [ -d "$MPI_ARCH_PATH"/intel64/lib ]
  then
    mpi_binpath="$MPI_ARCH_PATH"/intel64/bin
    mpi_ldpath="$MPI_ARCH_PATH"/intel64/lib:"$MPI_ARCH_PATH"/intel64/lib/release
  elif [ -d "$MPI_ARCH_PATH"/bin ] \
    && [ -d "$MPI_ARCH_PATH"/lib ]
  then
    mpi_binpath="$MPI_ARCH_PATH"/bin
    mpi_ldpath="$MPI_ARCH_PATH"/lib:"$MPI_ARCH_PATH"/lib/release
  elif [ -d "$MPI_ARCH_PATH"/bin64 ] \
    && [ -d "$MPI_ARCH_PATH"/lib64 ]
  then
    mpi_binpath="$MPI_ARCH_PATH"/bin64
    mpi_ldpath="$MPI_ARCH_PATH"/lib64
  fi
fi


cat > ${module_file} <<EOF
#%Module -*- tcl -*-
##
## modulefile
##
proc ModulesHelp { } {

  puts stderr "\tAdds OpenFOAM-${version}"
}

module-whatis "Adds OpenFOAM-${version}"

set    version     ${version}
set    root        $(realpath -s $program_dir)
set    thirdparty  \$root/ThirdParty-\$version
set    foam        \$root/OpenFOAM-\$version
set    arch        linux64
set    mpi         intelmpi
set    mpilib      ${mpi_ldpath}
set    mpibin      ${mpi_binpath}
set    compiler    Icc
set    precision   DP
set    compile_opt Opt
set    opts        \$arch\$compiler\$precision\$compile_opt

setenv WM_PROJECT_INST_DIR     \$root
setenv FOAM_INST_DIR           \$root
setenv FOAM_JOB_DIR            \$root/jobControl
setenv OpenFOAM_DIR            \$foam
setenv WM_THIRD_PARTY_DIR      \$thirdparty
setenv CGAL_ARCH_PATH          \$thirdparty/platforms/\$arch\$compiler/CGAL-4.3
setenv BOOST_ARCH_PATH         \$thirdparty/platforms/\$arch\$compiler/boost_1_54_0

setenv WM_OPTIONS              \$opts
setenv WM_COMPILE_OPTION       \$compile_opt
setenv WM_PRECISION_OPTION     \$precision
setenv WM_ARCH                 \$arch
setenv WM_PROJECT_VERSION      \$version
setenv WM_COMPILER             \$compiler
setenv WM_PROJECT_DIR          \$foam

setenv WM_LINK_LANGUAGE        c++
setenv WM_OSTYPE               POSIX
setenv WM_COMPILER_LIB_ARCH    64
setenv WM_CC                   gcc
setenv WM_CXX                  g++
setenv WM_CFLAGS               "-m64 -fPIC"
setenv WM_CXXFLAGS             "-m64 -fPIC"
setenv WM_LDFLAGS              -m64
setenv WM_MPLIB                INTELMPI
setenv MPI_BUFFER_SIZE         20000000
setenv WM_PROJECT              OpenFOAM
setenv WM_ARCH_OPTION          64
setenv WM_DIR                  \$foam/wmake
setenv FOAM_SOLVERS            \$foam/applications/solvers
setenv MKL_NUM_THREADS  1
setenv FOAM_MPI                \$mpi
setenv FOAM_EXT_LIBBIN         \$thirdparty/platforms/\$opts/lib
setenv FOAM_TUTORIALS          \$foam/tutorials
setenv FOAM_APPBIN             \$foam/platforms/\$opts/bin
setenv FOAM_LIBBIN             \$foam/platforms/\$opts/lib
setenv FOAM_SRC                \$foam/src
setenv FOAM_APP                \$foam/applications
setenv FOAM_UTILITIES          \$foam/applications/utilities

prepend-path LD_LIBRARY_PATH   \$foam/platforms/\$opts/lib/dummy
prepend-path LD_LIBRARY_PATH   \$thirdparty/platforms/\$opts/lib
prepend-path LD_LIBRARY_PATH   \$foam/platforms/\$opts/lib
prepend-path LD_LIBRARY_PATH   \$mpilib
prepend-path LD_LIBRARY_PATH   \$thirdparty/platforms/\$opts/lib\$mpi
prepend-path LD_LIBRARY_PATH   \$foam/platforms/\$opts/lib/\$mpi
prepend-path LD_LIBRARY_PATH   \$thirdparty/platforms/\$arch\$compiler/boost_1_54_0/lib

prepend-path PATH              \$foam/wmake
prepend-path PATH              \$foam/bin
prepend-path PATH              \$foam/platforms/\$opts/bin
prepend-path PATH              \$mpibin

# vim: filetype=tcl:

EOF


