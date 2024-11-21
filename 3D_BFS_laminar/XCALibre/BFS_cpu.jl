using XCALibre
using Downloads
using ThreadPinning

mesh_file = "bfs_tet_5mm.unv"

isfile(mesh_file) ? nothing : Downloads.download(
    "http://www.aerofluids.org/XCALibre/grids/3D_BFS/bfs_tet_5mm.unv", mesh_file
    )

mesh = UNV3D_mesh(mesh_file, scale=0.001)

nthreads = Threads.nthreads()
pinthreads(:cores)



ncells = mesh.cells |> length
workgroup = cld(ncells, nthreads)
workgroup = iseven(workgroup) ? workgroup : workgroup + 1 


backend = CPU()
if pkgversion(XCALibre) !== v"0.3.2"
    activate_multithread(backend)
end

mesh_dev = mesh

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

@assign! model momentum U ( 
    Dirichlet(:inlet, velocity),
    Neumann(:outlet, 0.0),
    Wall(:wall, noSlip),
    Neumann(:sides, 0.0),
    Neumann(:top, 0.0)
)

@assign! model momentum p (
    Neumann(:inlet, 0.0),
    Dirichlet(:outlet, 0.0),
    Neumann(:wall, 0.0),
    Neumann(:sides, 0.0),
    Neumann(:top, 0.0)
)

solvers = (
    U = set_solver(
        model.momentum.U;
        solver      = BicgstabSolver, # BicgstabSolver, GmresSolver
        preconditioner = Jacobi(),
        convergence = 1e-7,
        relax       = 0.8,
        rtol = 0.1
    ),
    p = set_solver(
        model.momentum.p;
        solver      = CgSolver, # BicgstabSolver, GmresSolver
        preconditioner = Jacobi(), #NormDiagonal(),
        convergence = 1e-7,
        relax       = 0.2,
        rtol = 0.1,
        itmax = 1000
    )
)

schemes = (
    U = set_schemes(time=SteadyState, divergence=Upwind, gradient=Midpoint),
    p = set_schemes(time=SteadyState, gradient=Midpoint)
)

hardware = set_hardware(backend=backend, workgroup=workgroup)

# Run first to pre-compile

runtime = set_runtime(iterations=1, write_interval=1, time_step=1)
config = Configuration(solvers=solvers, schemes=schemes, runtime=runtime, hardware=hardware)

GC.gc(true)

initialise!(model.momentum.U, velocity)
initialise!(model.momentum.p, 0.0)

residuals = run!(model, config)

# Now get timing information

runtime = set_runtime(iterations=500, write_interval=500, time_step=1)
config = Configuration(solvers=solvers, schemes=schemes, runtime=runtime, hardware=hardware)

GC.gc(true)

initialise!(model.momentum.U, velocity)
initialise!(model.momentum.p, 0.0)

exe_time = @elapsed residuals = run!(model, config)

# Write execution time to file 

open(ARGS[1]*".txt","a") do io
    println(io,"$nthreads,$workgroup,$exe_time")
end