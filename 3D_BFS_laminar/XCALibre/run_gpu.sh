#!/bin/bash

# fileName="0.3.2"

# julia -t 8 BFS_env_clean.jl
# julia -t 8 BFS_env_setup_v0.3.x.jl $fileName
# julia -t 1 BFS_gpu.jl $fileName

# fileName="0.3.3"

# julia -t 8 BFS_env_clean.jl
# julia -t 8 BFS_env_setup_v0.3.x.jl $fileName
# julia -t 1 BFS_gpu.jl $fileName

fileName="0.5.0"

julia -t 8 BFS_env_clean.jl
julia -t 8 BFS_env_setup_v0.5.0.jl $fileName
julia -t 1 BFS_gpu_v0.5.0.jl $fileName

rm -rf *.vtk
rm -rf *.vtu
