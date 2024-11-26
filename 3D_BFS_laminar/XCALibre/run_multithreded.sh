#!/bin/bash

fileName="0.3.2"

julia -e 'using Pkg; Pkg.rm("XCALibre"); Pkg.add(name="XCALibre", version="0.3.2")'

julia -t 1 BFS_cpu.jl $fileName
julia -t 2 BFS_cpu.jl $fileName
julia -t 4 BFS_cpu.jl $fileName
julia -t 6 BFS_cpu.jl $fileName
julia -t 8 BFS_cpu.jl $fileName


fileName="0.3.3"

julia -e 'using Pkg; "XCALibre" in keys(Pkg.project().dependencies) && Pkg.rm("XCALibre"); Pkg.develop(path="/home/humberto/JULIA/XCALibre.jl/")'

julia -t 1 BFS_cpu.jl $fileName
julia -t 2 BFS_cpu.jl $fileName
julia -t 4 BFS_cpu.jl $fileName
julia -t 6 BFS_cpu.jl $fileName
julia -t 8 BFS_cpu.jl $fileName

rm -rf *.vtk
rm -rf *.vtu