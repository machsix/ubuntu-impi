--%Module1.0
-- Intel oneAPI module
whatis("Name: Intel OneAPI")
whatis("Version: 2023.2.0")  -- Adjust version as needed
whatis("Category: Development")
whatis("Description: Intel OneAPI")
family("compiler")

-- Environment variables
local oneapi_root = "/opt/intel/oneapi"

-- Set environmental variable for Intel oneAPI root directory
setenv("ONEAPI_ROOT", oneapi_root)
setenv("CC", "mpiicc")
setenv("CXX", "mpiicpc")
setenv("FC", "mpiifort")
setenv("F90", "mpiifort")

-- Set PATH for various Intel oneAPI tools
prepend_path("PATH", pathJoin(oneapi_root, "vtune/latest/bin64"))
prepend_path("PATH", pathJoin(oneapi_root, "vpl/latest/bin"))
prepend_path("PATH", pathJoin(oneapi_root, "mpi/latest/libfabric/bin"))
prepend_path("PATH", pathJoin(oneapi_root, "mpi/latest/bin"))
prepend_path("PATH", pathJoin(oneapi_root, "mkl/latest/bin/intel64"))
prepend_path("PATH", pathJoin(oneapi_root, "itac/latest/bin"))
prepend_path("PATH", pathJoin(oneapi_root, "inspector/latest/bin64"))
prepend_path("PATH", pathJoin(oneapi_root, "dpcpp-ct/latest/bin"))
prepend_path("PATH", pathJoin(oneapi_root, "dev-utilities/latest/bin"))
prepend_path("PATH", pathJoin(oneapi_root, "debugger/latest/gdb/intel64/bin"))
prepend_path("PATH", pathJoin(oneapi_root, "compiler/latest/linux/lib/oclfpga/llvm/aocl-bin"))
prepend_path("PATH", pathJoin(oneapi_root, "compiler/latest/linux/lib/oclfpga/bin"))
prepend_path("PATH", pathJoin(oneapi_root, "compiler/latest/linux/bin/intel64"))
prepend_path("PATH", pathJoin(oneapi_root, "clck/latest/bin/intel64"))
prepend_path("PATH", pathJoin(oneapi_root, "advisor/latest/bin64"))
prepend_path("PATH", pathJoin(oneapi_root, "compiler/latest/bin"))

-- Set PKG_CONFIG_PATH for various Intel oneAPI tools
prepend_path("PKG_CONFIG_PATH", pathJoin(oneapi_root, "vtune/latest/include/pkgconfig/lib64"))
prepend_path("PKG_CONFIG_PATH", pathJoin(oneapi_root, "vpl/latest/lib/pkgconfig"))
prepend_path("PKG_CONFIG_PATH", pathJoin(oneapi_root, "mkl/latest/tools/pkgconfig"))
prepend_path("PKG_CONFIG_PATH", pathJoin(oneapi_root, "inspector/latest/include/pkgconfig/lib64"))
prepend_path("PKG_CONFIG_PATH", pathJoin(oneapi_root, "advisor/latest/include/pkgconfig/lib64"))

-- Set additional environment variables for specific tools
setenv("ADVISOR_2023_DIR", pathJoin(oneapi_root, "advisor/latest"))
prepend_path("PYTHONPATH", pathJoin(oneapi_root, "advisor/latest/pythonapi"))
setenv("APM", pathJoin(oneapi_root, "advisor/latest/perfmodels"))
setenv("CCL_ROOT", pathJoin(oneapi_root, "ccl/latest"))
setenv("CCL_CONFIGURATION", "cpu_gpu_dpcpp")

-- Set CPATH for various Intel oneAPI tools
prepend_path("CPATH", pathJoin(oneapi_root, "vpl/latest/include"))
prepend_path("CPATH", pathJoin(oneapi_root, "tbb/latest/env/../include"))
prepend_path("CPATH", pathJoin(oneapi_root, "mpi/latest/include"))
prepend_path("CPATH", pathJoin(oneapi_root, "mkl/latest/include"))
prepend_path("CPATH", pathJoin(oneapi_root, "ipp/latest/include"))
prepend_path("CPATH", pathJoin(oneapi_root, "ippcp/latest/include"))
prepend_path("CPATH", pathJoin(oneapi_root, "ipp/latest/include"))
prepend_path("CPATH", pathJoin(oneapi_root, "dpl/latest/linux/include"))
prepend_path("CPATH", pathJoin(oneapi_root, "dpcpp-ct/latest/include"))
prepend_path("CPATH", pathJoin(oneapi_root, "dnnl/latest/cpu_dpcpp_gpu_dpcpp/lib"))
prepend_path("CPATH", pathJoin(oneapi_root, "dev-utilities/latest/include"))
prepend_path("CPATH", pathJoin(oneapi_root, "dal/latest/include"))
prepend_path("CPATH", pathJoin(oneapi_root, "compiler/latest/linux/include"))
prepend_path("CPATH", pathJoin(oneapi_root, "ccl/latest/include/cpu_gpu_dpcpp"))

-- Set LIBRARY_PATH for various Intel oneAPI tools
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "vpl/latest/lib"))
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "tbb/latest/env/../lib/intel64/gcc4.8"))
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "mpi/latest/libfabric/lib"))
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "mpi/latest/lib/release"))
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "mpi/latest/lib"))
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "mkl/latest/lib/intel64"))
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "ipp/latest/lib/intel64"))
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "ippcp/latest/lib/intel64"))
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "ipp/latest/lib/intel64"))
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "dnnl/latest/cpu_dpcpp_gpu_dpcpp/lib"))
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "dal/latest/lib/intel64"))
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "compiler/latest/linux/compiler/lib/intel64_lin"))
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "compiler/latest/linux/lib"))
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "clck/latest/lib/intel64"))
prepend_path("LIBRARY_PATH", pathJoin(oneapi_root, "ccl/latest/lib/cpu_gpu_dpcpp"))

-- Set LD_LIBRARY_PATH for various Intel oneAPI tools
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "vpl/latest/lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "tbb/latest/env/../lib/intel64/gcc4.8"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "mpi/latest/libfabric/lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "mpi/latest/lib/release"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "mpi/latest/lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "mkl/latest/lib/intel64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "itac/latest/slib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "ipp/latest/lib/intel64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "ippcp/latest/lib/intel64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "ipp/latest/lib/intel64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "dnnl/latest/cpu_dpcpp_gpu_dpcpp/lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "debugger/latest/gdb/intel64/lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "debugger/latest/libipt/intel64/lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "debugger/latest/dep/lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "dal/latest/lib/intel64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "compiler/latest/linux/lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "compiler/latest/linux/lib/x64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "compiler/latest/linux/lib/emu"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "compiler/latest/linux/lib/oclfpga/host/linux64/lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "compiler/latest/linux/lib/oclfpga/linux64/lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "compiler/latest/linux/compiler/lib/intel64_lin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(oneapi_root, "ccl/latest/lib/cpu_gpu_dpcpp"))

-- Set additional environment variables for specific tools
setenv("CLCK_ROOT", pathJoin(oneapi_root, "clck/latest"))
prepend_path("CPLUS_INCLUDE_PATH", pathJoin(oneapi_root, "clck/latest/include"))
setenv("INTEL_LICENSE_FILE", "/opt/intel/licenses:" .. pathJoin(oneapi_root, "clck/latest/licensing") .. ":/opt/intel/licenses:/home/hluo171851/intel/licenses")
prepend_path("MANPATH", pathJoin(oneapi_root, "mpi/latest/man"))
prepend_path("MANPATH", pathJoin(oneapi_root, "itac/latest/man"))
prepend_path("MANPATH", pathJoin(oneapi_root, "debugger/latest/documentation/man"))
prepend_path("MANPATH", pathJoin(oneapi_root, "compiler/latest/documentation/en/man/common"))
prepend_path("MANPATH", pathJoin(oneapi_root, "clck/latest/man"))

setenv("CMPLR_ROOT", pathJoin(oneapi_root, "compiler/latest"))
setenv("FPGA_VARS_DIR", pathJoin(oneapi_root, "compiler/latest/linux/lib/oclfpga"))
setenv("FPGA_VARS_ARGS", "")
setenv("OCL_ICD_FILENAMES", "libintelocl_emu.so:libalteracl.so:" .. pathJoin(oneapi_root, "compiler/latest/linux/lib/x64/libintelocl.so"))
setenv("ACL_BOARD_VENDOR_PATH", "/opt/Intel/OpenCLFPGA/oneAPI/Boards")
setenv("INTELFPGAOCLSDKROOT", pathJoin(oneapi_root, "compiler/latest/linux/lib/oclfpga"))
setenv("DAL_MAJOR_BINARY", 1)
setenv("DAL_MINOR_BINARY", 1)
setenv("DALROOT", pathJoin(oneapi_root, "dal/latest"))
setenv("DAALROOT", pathJoin(oneapi_root, "dal/latest"))
setenv("CLASSPATH", pathJoin(oneapi_root, "mpi/latest/lib/mpi.jar") .. ":" .. pathJoin(oneapi_root, "dal/latest/lib/onedal.jar"))
setenv("CMAKE_PREFIX_PATH", pathJoin(oneapi_root, "vpl/latest") .. ":" .. pathJoin(oneapi_root, "tbb/latest/env/..") .. ":" .. pathJoin(oneapi_root, "dal/latest"))
setenv("INTEL_PYTHONHOME", pathJoin(oneapi_root, "debugger/latest/dep"))
setenv("INFOPATH", pathJoin(oneapi_root, "debugger/latest/gdb/intel64/lib"))
setenv("DNNLROOT", pathJoin(oneapi_root, "dnnl/latest/cpu_dpcpp_gpu_dpcpp"))
setenv("DPCT_BUNDLE_ROOT", pathJoin(oneapi_root, "dpcpp-ct/latest"))
setenv("DPL_ROOT", pathJoin(oneapi_root, "dpl/latest"))
setenv("INSPECTOR_2023_DIR", pathJoin(oneapi_root, "inspector/latest"))

-- Note: Commented out conda-related exports
-- setenv("CONDA_EXE", pathJoin(oneapi_root, "intelpython/latest/bin/conda"))
-- setenv("_CE_M", "")
-- setenv("_CE_CONDA", "")
-- setenv("CONDA_PYTHON_EXE", pathJoin(oneapi_root, "intelpython/latest/bin/python"))
-- setenv("CONDA_SHLVL", 1)
-- setenv("CONDA_PREFIX", pathJoin(oneapi_root, "intelpython/latest"))
-- setenv("CONDA_DEFAULT_ENV", "intelpython-python3.7")
-- setenv("CONDA_PROMPT_MODIFIER", "(intelpython-python3.7)")

setenv("IPPROOT", pathJoin(oneapi_root, "ipp/latest"))
setenv("IPP_TARGET_ARCH", "intel64")
setenv("IPPCRYPTOROOT", pathJoin(oneapi_root, "ippcp/latest"))
setenv("IPPCP_TARGET_ARCH", "intel64")
setenv("VT_ROOT", pathJoin(oneapi_root, "itac/latest"))
setenv("VT_MPI", "impi4")
setenv("VT_LIB_DIR", pathJoin(oneapi_root, "itac/latest/lib"))
setenv("VT_SLIB_DIR", pathJoin(oneapi_root, "itac/latest/slib"))
setenv("VT_ADD_LIBS", "-ldwarf -lelf -lvtunwind -lm -lpthread")
setenv("MKLROOT", pathJoin(oneapi_root, "mkl/latest"))
setenv("NLSPATH", pathJoin(oneapi_root, "mkl/latest/lib/intel64/locale/%l_%t/%N"))
setenv("I_MPI_ROOT", pathJoin(oneapi_root, "mpi/latest"))
setenv("FI_PROVIDER_PATH", pathJoin(oneapi_root, "mpi/latest/libfabric/lib/prov:/usr/lib64/libfabric"))
setenv("TBBROOT", pathJoin(oneapi_root, "tbb/latest/env/.."))
setenv("VTUNE_PROFILER_2023_DIR", pathJoin(oneapi_root, "vtune/latest"))

-- Function to append flag to an environment variable
local function append_flag(env_var, flag)
    local current_value = os.getenv(env_var)
    if current_value then
        prepend_path(env_var, flag, " ")
    else
        setenv(env_var, flag)
    end
end

-- Append -diag-disable=10441 to CFLAGS
append_flag("CFLAGS", "-diag-disable=10441")

-- Append -diag-disable=10441 to CXXFLAGS
append_flag("CXXFLAGS", "-diag-disable=10441")

-- If the module is unloaded, remove the flag
if (mode() == "unload") then
  local function remove_flag(env_var, flag)
    local current_value = os.getenv(env_var)
    if current_value then
      current_value = string.gsub(current_value, "%s*%-diag%-disable=10441", "")
      setenv(env_var, current_value)
    end
  end

  -- Remove -diag-disable=10441 from CFLAGS
  remove_flag("CFLAGS", "-diag-disable=10441")

  -- Remove -diag-disable=10441 from CXXFLAGS
  remove_flag("CXXFLAGS", "-diag-disable=10441")
end
