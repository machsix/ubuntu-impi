help([[
   Hypre 2.32.0 - Auto-detects and loads the correct compiler version.
]])

family("hypre")

local version = "2.32.0"
-- Check loaded compiler
if isloaded("intel") then
  load("hypre/intel/" .. version)
elseif isloaded("nvhpc") then
  load("hypre/nvhpc/" .. version)
elseif isloaded("cuda") then
  load("hypre/cuda/" .. version)
else
  LmodMessage("No supported compiler found! Load a compiler before loading Hypre.")
end
