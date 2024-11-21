using Plots
using DelimitedFiles

# Load benchmark results
of_similar = readdlm("openfoam_PCG_PBiCGStab_diag.txt", ',')
of_GAMG = readdlm("openfoam_GAMG_PBiCGStab_DILU.txt", ',')
xcal_033 = readdlm("0.3.3.txt", ',')
xcal_032 = readdlm("0.3.2.txt", ',')
xcal_033_gpu = readdlm("nvidia_benchmarks_0.3.3.txt", ',')
xcal_032_gpu = readdlm("nvidia_benchmarks_0.3.2.txt", ',')

# Plot execution time
default()
default(
    linewidth=2, marker=:circle, markersize=3, framestyle=:box, 
    foreground_color_legend = nothing, background_color_legend=nothing
    )
plot(
    xlabel="# processors", ylabel="Execution time (s)", 
    ylims=(50,2000), 
    )
plot!(of_similar[:,1], of_similar[:,2], label="OpenFOAM - PGC Bicgstab (diagonal)")
plot!(of_GAMG[:,1], of_GAMG[:,2], label="OpenFOAM - GAMG Bicgstab (DILU)")
plot!(xcal_033[:,1], xcal_033[:,3], label="XCALibre 0.3.3 - PGC Bicgstab (diagonal)")
plot!(xcal_032[:,1], xcal_032[:,3], label="XCALibre 0.3.2 - PGC Bicgstab (diagonal)")
gpu_time_032 = xcal_033_gpu[1,2]
gpu_time_031 = xcal_032_gpu[1,2]

plot!([1,8], [gpu_time_032, gpu_time_032], color=3,marker=:none, label="XCALibre 0.3.3 - NVIDIA GeForce RTX 2060")
plot!([1,8], [gpu_time_031, gpu_time_031], color=4, marker=:none, label="XCALibre 0.3.2 - NVIDIA GeForce RTX 2060")
savefig("fig_execution_time_comparision.svg")
savefig("fig_execution_time_comparision.png")

# Speed up compared to XCALibre v0.3.1
ref = xcal_032[1,3]
plot(
    xlabel="# processors", ylabel="Speed up compared to v0.3.2 (1 thread)", # yaxis=:log10
    ylims=(0,19), yticks=(0:1:19),legend=:outertopright
    )
plot!(of_similar[:,1], ref./of_similar[:,2], label="OpenFOAM - Comparable")
plot!(of_GAMG[:,1], ref./of_GAMG[:,2], label="OpenFOAM - GAMG")
plot!(xcal_033[:,1], ref./xcal_033[:,3], label="XCALibre 0.3.3")
plot!(xcal_032[:,1], ref./xcal_032[:,3], label="XCALibre 0.3.2")
gpu_time_032 = ref./xcal_033_gpu[1,2]
gpu_time_031 = ref./xcal_032_gpu[1,2]

plot!([1,8], [gpu_time_032, gpu_time_032], color=3,marker=:none, label="XCALibre 0.3.3 - RTX 2060")
plot!([1,8], [gpu_time_031, gpu_time_031], color=4, marker=:none, label="XCALibre 0.3.2 - RTX 2060")
savefig("fig_speedup_vs_v0.3.2.svg")
savefig("fig_speedup_vs_v0.3.2.png")

# Performance when using workgroup with sizes of 2^n
# plot(; xaxis=:linear, yaxis=:linear, ylims=(200,800), framestyle=:box)
# plot!(xcal_033[:,1], xcal_033[:,3], label="XCALibre - PGC Bicgstab (diagonal)")
# plot!(xcal_033_pow2[:,1], xcal_033_pow2[:,3], label="XCALibre - PGC Bicgstab (diagonal)")


# Scaling plot
plot(
    xlabel = "# processors", ylabel="Parallel scaling",
    ylims=(1,6)
    )
plot!(of_similar[:,1], of_similar[1,2]./of_similar[:,2], label="OpenFOAM - PGC Bicgstab (diagonal)")
plot!(of_GAMG[:,1], of_GAMG[1,2]./of_GAMG[:,2], label="OpenFOAM - GAMG Bicgstab (DILU)")
plot!(xcal_033[:,1], xcal_033[1,3]./xcal_033[:,3], label="XCALibre 0.3.3")
plot!(xcal_032[:,1], xcal_032[1,3]./xcal_032[:,3], label="XCALibre 0.3.2")
plot!(1:8, 1:8, label="Ideal scaling", color=:black)
# plot!(xcal_033_pow2[:,1], xcal_033_pow2[1,3]./xcal_033_pow2[:,3], label="XCALibre - PGC Bicgstab (diagonal)")
savefig("fig_parallel_scaling.svg")
savefig("fig_parallel_scaling.png")
