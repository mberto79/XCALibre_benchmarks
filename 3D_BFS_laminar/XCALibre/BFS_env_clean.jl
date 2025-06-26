import Pkg; Pkg.activate(".")
"XCALibre" in keys(Pkg.project().dependencies) && Pkg.rm("XCALibre")
"CUDA" in keys(Pkg.project().dependencies) && Pkg.rm("CUDA")
Pkg.resolve()
