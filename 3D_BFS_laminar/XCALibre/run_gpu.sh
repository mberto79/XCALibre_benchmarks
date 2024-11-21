#!/bin/bash

# wget http://www.aerofluids.org/XCALibre/grids/3D_BFS/bfs_tet_5mm.unv

fileName="0.3.2"

julia -e 'using Pkg; "XCALibre" in keys(Pkg.project().dependencies) && Pkg.rm("XCALibre"); Pkg.add(name="XCALibre", version="0.3.2")'

julia -t 1 BFS_gpu.jl $fileName

fileName="0.3.3"

julia -e 'using Pkg; Pkg.rm("XCALibre"); Pkg.develop(path="/home/humberto/JULIA/XCALibre.jl/")'

julia -t 1 BFS_gpu.jl $fileName

rm -rf *.vtk
rm -rf *.vtu