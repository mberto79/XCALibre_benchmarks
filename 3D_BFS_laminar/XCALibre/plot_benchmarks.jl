using Plots
using DelimitedFiles

# Test/create output figure directory
isdir("figures") || mkdir("figures")

# Load benchmark results
of_similar = readdlm("openfoam_PCG_PBiCGStab_diag.txt", ',')
of_GAMG = readdlm("openfoam_GAMG_PBiCGStab_DILU.txt", ',')
xcal_032 = readdlm("multithread_0.3.2.txt", ',')
xcal_033 = readdlm("multithread_0.3.3.txt", ',')
xcal_050 = readdlm("multithread_0.5.0.txt", ',')
xcal_032_gpu = readdlm("nvidia_0.3.2.txt", ',')
xcal_033_gpu = readdlm("nvidia_0.3.3.txt", ',')
xcal_050_gpu = readdlm("nvidia_0.5.0.txt", ',')

# Plot execution time
default()
default(
    linewidth=2, marker=:circle, markersize=3, framestyle=:box, 
    foreground_color_legend = nothing, background_color_legend=nothing
    )
    r = round.(10.0.^(1.70:0.15:3.2), digits=2)
plot(
    xlabel="# processors", ylabel="Execution time (s)", 
    ylims=(50,2000), 
    yticks = (r, r),
    yaxis = :log10,
    legend=:outertopright,
    )
plot!(of_similar[:,1], of_similar[:,2], label="OF11 Similar")
plot!(of_GAMG[:,1], of_GAMG[:,2], label="OF11 Best")
plot!(xcal_032[:,1], xcal_032[:,3], label="v0.3.2")
plot!(xcal_033[:,1], xcal_033[:,3], label="v0.3.3")
plot!(xcal_050[:,1], xcal_050[:,3], label="v0.5.0")
gpu_time_032 = xcal_032_gpu[1,2]
gpu_time_033 = xcal_033_gpu[1,2]
gpu_time_050 = xcal_050_gpu[1,2]

plot!([1,8], [gpu_time_032, gpu_time_032], color=4, marker=:none, label="v0.3.2 GPU")
plot!([1,8], [gpu_time_033, gpu_time_033], color=3,marker=:none, label="v0.3.3 GPU")
plot!([1,8], [gpu_time_050, gpu_time_050], color=5,marker=:none, label="v0.5.0 GPU")
savefig("figures/execution_time_comparision.svg")
savefig("figures/execution_time_comparision.png")

# Speed up compared to XCALibre v0.3.1
ref = xcal_032[1,3]
# ref = of_similar[1,2]
# ref = of_GAMG[1,2]
upper_limit = 22
plot(
    xlabel="# processors", ylabel="Speed up compared to v0.3.2 (1 thread)", # yaxis=:log10
    ylims=(0,upper_limit), 
    yticks=(0:1:upper_limit),
    legend=:outertopright,

    )
plot!(of_similar[:,1], ref./of_similar[:,2], label="OF11 Similar")
plot!(of_GAMG[:,1], ref./of_GAMG[:,2], label="OF11 Best")
plot!(xcal_032[:,1], ref./xcal_032[:,3], label="v0.3.2")
plot!(xcal_033[:,1], ref./xcal_033[:,3], label="v0.3.3")
plot!(xcal_050[:,1], ref./xcal_050[:,3], label="v0.5.0")
gpu_time_032 = ref./xcal_032_gpu[1,2]
gpu_time_033 = ref./xcal_033_gpu[1,2]
gpu_time_050 = ref./xcal_050_gpu[1,2]

plot!([1,8], [gpu_time_032, gpu_time_032], color=3, marker=:none, label="v0.3.2 GPU")
plot!([1,8], [gpu_time_033, gpu_time_033], color=4,marker=:none, label="v0.3.3 GPU")
plot!([1,8], [gpu_time_050, gpu_time_050], color=5,marker=:none, label="v0.5.0 GPU")
savefig("figures/speedup_vs_v0.3.2.svg")
savefig("figures/speedup_vs_v0.3.2.png")

# Scaling plot
plot(
    xlabel = "# processors", 
    ylabel="Parallel scaling",
    yaxis = :log10,
    ylims= (1,8),
    xlims= (1,10),
    yticks = (1:8, string.(1:8)),
    xticks = (1:10, string.(1:10)),
    xaxis = :log10, 
   )
plot!(of_similar[:,1], of_similar[1,2]./of_similar[:,2], label="OF11 Similar")
plot!(of_GAMG[:,1], of_GAMG[1,2]./of_GAMG[:,2], label="OF11 Best")
plot!(xcal_032[:,1], xcal_032[1,3]./xcal_032[:,3], label="v0.3.2")
plot!(xcal_033[:,1], xcal_033[1,3]./xcal_033[:,3], label="v0.3.3")
plot!(xcal_050[:,1], xcal_050[1,3]./xcal_050[:,3], label="v0.5.0")
plot!(1:8, 1:8, label="Ideal scaling", color=:black)

savefig("figures/parallel_scaling.svg")
savefig("figures/parallel_scaling.png")

