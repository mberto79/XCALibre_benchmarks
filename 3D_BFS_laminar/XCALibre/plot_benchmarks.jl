using Plots
using DelimitedFiles

# Test/create output figure directory
isdir("figures") || mkdir("figures")

# Load benchmark results
of_similar = readdlm("openfoam_PCG_PBiCGStab_diag.txt", ',')
of_GAMG = readdlm("openfoam_GAMG_PBiCGStab_DILU.txt", ',')
xcal_033 = readdlm("multithread_0.3.3.txt", ',')
xcal_032 = readdlm("multithread_0.3.2.txt", ',')
xcal_033_gpu = readdlm("nvidia_0.3.3.txt", ',')
xcal_032_gpu = readdlm("nvidia_0.3.2.txt", ',')

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
plot!(of_similar[:,1], of_similar[:,2], label="OF11 Similar")
plot!(of_GAMG[:,1], of_GAMG[:,2], label="OF11 Best")
plot!(xcal_033[:,1], xcal_033[:,3], label="v0.3.3")
plot!(xcal_032[:,1], xcal_032[:,3], label="v0.3.2")
gpu_time_032 = xcal_033_gpu[1,2]
gpu_time_031 = xcal_032_gpu[1,2]

plot!([1,8], [gpu_time_032, gpu_time_032], color=3,marker=:none, label="v0.3.3 GPU")
plot!([1,8], [gpu_time_031, gpu_time_031], color=4, marker=:none, label="v0.3.2 GPU")
savefig("figures/execution_time_comparision.svg")
savefig("figures/execution_time_comparision.png")

# Speed up compared to XCALibre v0.3.1
ref = xcal_032[1,3]
plot(
    xlabel="# processors", ylabel="Speed up compared to v0.3.2 (1 thread)", # yaxis=:log10
    ylims=(0,19), yticks=(0:1:19),legend=:outertopright
    )
plot!(of_similar[:,1], ref./of_similar[:,2], label="OF11 Similar")
plot!(of_GAMG[:,1], ref./of_GAMG[:,2], label="OF11 Best")
plot!(xcal_033[:,1], ref./xcal_033[:,3], label="v0.3.3")
plot!(xcal_032[:,1], ref./xcal_032[:,3], label="v0.3.2")
gpu_time_032 = ref./xcal_033_gpu[1,2]
gpu_time_031 = ref./xcal_032_gpu[1,2]

plot!([1,8], [gpu_time_032, gpu_time_032], color=3,marker=:none, label="v0.3.3 GPU")
plot!([1,8], [gpu_time_031, gpu_time_031], color=4, marker=:none, label="v0.3.2 GPU")
savefig("figures/speedup_vs_v0.3.2.svg")
savefig("figures/speedup_vs_v0.3.2.png")

# Scaling plot
plot(
    xlabel = "# processors", ylabel="Parallel scaling",
    ylims=(1,6)
    )
plot!(of_similar[:,1], of_similar[1,2]./of_similar[:,2], label="OF11 Similar")
plot!(of_GAMG[:,1], of_GAMG[1,2]./of_GAMG[:,2], label="OF11 Best")
plot!(xcal_033[:,1], xcal_033[1,3]./xcal_033[:,3], label="v0.3.3")
plot!(xcal_032[:,1], xcal_032[1,3]./xcal_032[:,3], label="v0.3.2")
plot!(1:8, 1:8, label="Ideal scaling", color=:black)

savefig("figures/parallel_scaling.svg")
savefig("figures/parallel_scaling.png")

