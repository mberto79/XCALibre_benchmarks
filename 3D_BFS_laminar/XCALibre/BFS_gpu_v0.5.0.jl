import Pkg
Pkg.activate(".")

using XCALibre
using CUDA
using Downloads
using JLD2

mesh_file = "bfs_tet_5mm.unv"

isfile(mesh_file) ? nothing : Downloads.download(
    "http://www.aerofluids.org/XCALibre/grids/3D_BFS/bfs_tet_5mm.unv", mesh_file
    )

mesh = nothing 
if isfile("mesh.jld2")  
    mesh = load_object("mesh.jld2")
else
    mesh = UNV3D_mesh(mesh_file, scale=0.001)
    save_object("mesh.jld2", mesh)
end


workgroup = 32
backend = CUDABackend()

mesh_dev = adapt(backend, mesh)

# Inlet conditions
velocity = [0.5, 0.0, 0.0]
noSlip = [0.0, 0.0, 0.0]
nu = 1e-3
Re = (0.2*velocity[1])/nu

model = Physics(
    time = Steady(),
    fluid = Fluid{Incompressible}(nu = nu),
    turbulence = RANS{Laminar}(),
    energy = Energy{Isothermal}(),
    domain = mesh_dev
    )

BCs = assign(
    region=mesh_dev,
    (
        U = [
            Dirichlet(:inlet, velocity),
            Zerogradient(:outlet),
            Wall(:wall, noSlip),
            Zerogradient(:sides),
            Zerogradient(:top)
        ],
        p = [
            Zerogradient(:inlet),
            Dirichlet(:outlet, 0.0),
            Wall(:wall),
            Extrapolated(:sides),
            Extrapolated(:top)
        ]
    )
)

solvers = (
    U = SolverSetup(
        solver      = Bicgstab(), # BicgstabSolver, GmresSolver
        preconditioner = Jacobi(),
        convergence = 1e-7,
        relax       = 0.8,
        rtol = 0.1
    ),
    p = SolverSetup(
        solver      = Cg(), # BicgstabSolver, GmresSolver
        preconditioner = Jacobi(), #NormDiagonal(),
        convergence = 1e-7,
        relax       = 0.2,
        rtol = 0.1,
        itmax = 1000
    )
)

schemes = (
    U = Schemes(time=SteadyState, divergence=Upwind, gradient=Gauss),
    p = Schemes(time=SteadyState, gradient=Gauss)
)

hardware = Hardware(backend=backend, workgroup=workgroup)

# Run first to pre-compile

runtime = Runtime(iterations=1, write_interval=1, time_step=1)

config = Configuration(
    solvers=solvers, schemes=schemes, runtime=runtime, hardware=hardware, boundaries=BCs)

GC.gc(true)

initialise!(model.momentum.U, velocity)
initialise!(model.momentum.p, 0.0)

residuals = run!(model, config)

# Now get timing information

runtime = Runtime(iterations=500, write_interval=500, time_step=1)

config = Configuration(
    solvers=solvers, schemes=schemes, runtime=runtime, hardware=hardware, boundaries=BCs)

GC.gc(true)

initialise!(model.momentum.U, velocity)
initialise!(model.momentum.p, 0.0)

exe_time = @elapsed residuals = run!(model, config)

# Write execution time to file 
filename = "nvidia_"*ARGS[1]*".txt"
open(filename,"a") do io
    println(io,"$workgroup,$exe_time")
end