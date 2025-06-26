import Pkg; Pkg.activate(".")
Pkg.develop(path="/home/humberto/JULIA/XCALibre.jl");
# Pkg.add(name="XCALibre", version="$(ARGS[1])")
Pkg.add("CUDA")
Pkg.resolve()
Pkg.instantiate()
