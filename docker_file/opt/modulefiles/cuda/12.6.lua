-- -*- lua -*-
help([[
CUDA Toolkit module file.
]])

-- Define module properties
whatis("Name: CUDA Toolkit")
whatis("Version: 12.6")  -- Adjust version as needed
whatis("Category: Development")
whatis("Description: NVIDIA CUDA Toolkit")
family("compiler")

-- Set paths (adjust accordingly)
local version = "12.6"
local base = "/usr/local/cuda-" .. version  -- Modify path if needed

prepend_path("PATH", pathJoin(base, "bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base, "lib64"))
prepend_path("C_INCLUDE_PATH", pathJoin(base, "include"))
prepend_path("CPLUS_INCLUDE_PATH", pathJoin(base, "include"))
prepend_path("LIBRARY_PATH", pathJoin(base, "lib64"))
prepend_path("MANPATH", pathJoin(base, "share/man"))

-- Set CMake CUDA architectures specifically for RTX 3080 (Compute Capability 8.6)
setenv("CMAKE_CUDA_ARCHITECTURES", "86")
setenv("CUDA_HOME", base)
setenv("CUDA_PATH", base)

-- Prevent conflicts with other CUDA versions
conflict("cuda")

