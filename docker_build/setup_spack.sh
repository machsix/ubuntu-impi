#!/bin/bash
SPACK_CONFIG_ROOT="/etc/spack"
SPACK_MODULES_ROOT=/opt/modulefiles_spack
SPACK_ROOT=/opt/spack
SPACK_INSTALL_ROOT=/opt/
SPACK_VERSION=${1:-0.23.1}

MKL_VERSION=$(basename $(readlink /opt/intel/oneapi/mkl/latest))
MPI_VERSION=$(basename $(readlink /opt/intel/oneapi/mpi/latest))
COMPILER_VERSION=$(basename $(readlink /opt/intel/oneapi/compiler/latest))

# bootstrap configuration
mkdir -p ${SPACK_CONFIG_ROOT}
cp -a ${SPACK_ROOT}/etc/spack/defaults/config.yaml ${SPACK_CONFIG_ROOT}/config.yaml
yq -i ".config.install_tree.root = \"${SPACK_INSTALL_ROOT}\"" ${SPACK_CONFIG_ROOT}/config.yaml
yq -i '.config.install_tree.projections.all="{architecture.platform}-{architecture.os}/{name}-{version}-{hash}"' ${SPACK_CONFIG_ROOT}/config.yaml
ln -sf ${SPACK_CONFIG_ROOT} /root/.spack

# load spack
source ${SPACK_ROOT}/share/spack/setup-env.sh
cat > /etc/profile.d/z01_spack.sh << EOF
SPACK_ROOT=${SPACK_ROOT}
source \${SPACK_ROOT}/share/spack/setup-env.sh
EOF

# setup spack config
spack compiler find
spack external find

# setup intel compilers
source /opt/intel/oneapi/setvars.sh --force
yq -i "
  .compilers[] |=
    (select(.compiler.spec | test(\"^intel@\"))
      .compiler.environment = {
        \"prepend_path\": {
          \"LD_LIBRARY_PATH\": \"/opt/intel/oneapi/compiler/${COMPILER_VERSION}/linux/compiler/lib/intel64\",
          \"LIBRARY_PATH\": \"/opt/intel/oneapi/compiler/${COMPILER_VERSION}/linux/compiler/lib/intel64\"
        }
      }
    // .)
" ${SPACK_CONFIG_ROOT}/linux/compilers.yaml
yq -i "
  .packages.\"intel-oneapi-mpi\".externals = [{\"spec\": \"intel-oneapi-mpi@${MPI_VERSION}\", \"prefix\": \"/opt/intel/oneapi\"}] |
  .packages.\"intel-oneapi-mkl\".externals = [{\"spec\": \"intel-oneapi-mkl@${MKL_VERSION}\", \"prefix\": \"/opt/intel/oneapi\"}]
" ${SPACK_CONFIG_ROOT}/packages.yaml


# setup spack modules
mkdir -p /opt/modulefiles/spack
spack config rm modules:default:enable
spack config add modules:default:enable:[tcl,lmod]
cat >> /etc/profile.d/z00_lmod.sh << EOF
# Lmod configuration for Spack
export MODULEPATH=${SPACK_ROOT}/share/spack/modules/$(spack arch):\${MODULEPATH}
export MODULEPATH=${SPACK_ROOT}/share/spack/modules/linux-ubuntu22.04-x86_64_v3:\${MODULEPATH}
export MODULEPATH=/opt/modulefiles:\${MODULEPATH}
EOF
spack config add modules:default:tcl:projections:all:'"{name}/{version}-{compiler.name}"'
spack config add modules:default:tcl:projections:%gcc:'"{name}/{version}-{compiler.name}-{compiler.version}"'
spack config add modules:default:tcl:hash_length:0
spack config add modules:default:tcl:exclude_implicit:True
spack config add concretizer:os_compatible:$(spack arch -o):[ubuntu22.04]
spack solve zlib

spack module tcl refresh --delete-tree -y