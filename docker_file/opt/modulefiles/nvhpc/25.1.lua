-- -*- lua -*-
-- Module file created by NVIDIA CORPORATION

-- Display help message
help([[
NVIDIA HPC SDK 25.1

NVIDIA HPC SDK is a comprehensive suite of compilers, libraries, and tools for high performance computing.
]])

-- Module description
whatis("Name: NVIDIA HPC SDK")
whatis("Version: 25.1")
whatis("Category: Compiler")
whatis("Description: NVIDIA HPC SDK is a comprehensive suite of compilers, libraries, and tools for high performance computing.")
family("compiler")

-- Conflicts
conflict("nvhpc")
conflict("nvhpc-nompi")
conflict("nvhpc-byo-compiler")
conflict("nvhpc-hpcx")

-- Set environment variables
local nvhome = "/opt/nvidia/hpc_sdk"
local target = "Linux_x86_64"
local version = "25.1"

local nvcudadir = pathJoin(nvhome, target, version, "cuda")
local nvcompdir = pathJoin(nvhome, target, version, "compilers")
local nvmathdir = pathJoin(nvhome, target, version, "math_libs")
local nvcommdir = pathJoin(nvhome, target, version, "comm_libs")

setenv("NVHPC", nvhome)
setenv("NVHPC_ROOT", pathJoin(nvhome, target, version))
setenv("CC", pathJoin(nvcompdir, "bin", "nvc"))
setenv("CXX", pathJoin(nvcompdir, "bin", "nvc++"))
setenv("FC", pathJoin(nvcompdir, "bin", "nvfortran"))
setenv("F90", pathJoin(nvcompdir, "bin", "nvfortran"))
setenv("F77", pathJoin(nvcompdir, "bin", "nvfortran"))
setenv("CPP", "cpp")

-- Modify PATH
prepend_path("PATH", pathJoin(nvcudadir, "bin"))
prepend_path("PATH", pathJoin(nvcompdir, "bin"))
prepend_path("PATH", pathJoin(nvcommdir, "mpi", "bin"))
prepend_path("PATH", pathJoin(nvcompdir, "extras", "qd", "bin"))

-- Modify LD_LIBRARY_PATH
prepend_path("LD_LIBRARY_PATH", pathJoin(nvcudadir, "lib64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(nvcompdir, "extras", "qd", "lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(nvcompdir, "lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(nvmathdir, "lib64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(nvcommdir, "nccl", "lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(nvcommdir, "nvshmem", "lib"))

-- Modify CPATH
prepend_path("CPATH", pathJoin(nvmathdir, "include"))
prepend_path("CPATH", pathJoin(nvcommdir, "nccl", "include"))
prepend_path("CPATH", pathJoin(nvcommdir, "nvshmem", "include"))
prepend_path("CPATH", pathJoin(nvcompdir, "extras", "qd", "include", "qd"))

-- Modify C_INCLUDE_PATH
prepend_path("C_INCLUDE_PATH", pathJoin(nvmathdir, "include"))
prepend_path("C_INCLUDE_PATH", pathJoin(nvcommdir, "nccl", "include"))
prepend_path("C_INCLUDE_PATH", pathJoin(nvcommdir, "nvshmem", "include"))
prepend_path("C_INCLUDE_PATH", pathJoin(nvcompdir, "extras", "qd", "include", "qd"))

-- Modify CPLUS_INCLUDE_PATH
prepend_path("CPLUS_INCLUDE_PATH", pathJoin(nvmathdir, "include"))
prepend_path("CPLUS_INCLUDE_PATH", pathJoin(nvcommdir, "nccl", "include"))
prepend_path("CPLUS_INCLUDE_PATH", pathJoin(nvcommdir, "nvshmem", "include"))
prepend_path("CPLUS_INCLUDE_PATH", pathJoin(nvcompdir, "extras", "qd", "include", "qd"))

-- Modify MANPATH
prepend_path("MANPATH", pathJoin(nvcompdir, "man"))
