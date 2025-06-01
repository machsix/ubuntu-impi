help([[
Adds hypre/2.32.0 to your environment variables.
]])

whatis("Adds hypre to your environment variables")

load("nvhpc")

local version = "2.32.0"
local root = "/opt/hypre/nvhpc/2.32.0"

prepend_path("LD_LIBRARY_PATH", pathJoin(root, "lib"))
setenv("HYPRE", root)
