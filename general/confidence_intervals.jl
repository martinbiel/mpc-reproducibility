using Random
using DABenchmarks
using LaTeXStrings
using DelimitedFiles
using Plots
pyplot()

Random.seed!(0)

using Distributed
machine = [("MACHINENAME", 28)]
addprocs(machine, dir = "/home/USER", exename="/path/to/julia", exeflags="--project") # Remove if worker processors are not available
# addprocs(28, exeflags="--project") # For local workers

@everywhere using StochasticPrograms
@everywhere using LShapedSolvers
@everywhere using HydroModels
@everywhere using Gurobi

function confidence_intervals(sample_sizes::Vector{Int}, solver)
    intervals = zeros(length(sample_sizes))
    dayahead_data = HydroModels.NordPoolDayAheadData("data/plantdata.csv", "data/spotprices.csv", 1, 35.0, 60.0)
    sampler = DayAheadSampler(dayahead_data)
    dayahead_model = DayAheadModel(dayahead_data, sampler, 1, [:Skellefteälven])
    stochasticmodel = dayahead_model.stochasticmodel
    confidence = 0.95
    α = (1-confidence)/2
    saa = SAA(stochasticmodel, sampler, 2000)
    optimize!(saa, solver = solver)
    x̂ = optimal_decision(saa)
    Q, U = evaluate_decision(stochasticmodel, x̂, sampler; solver = solver, confidence = 1-α, N = 2000)
    for (i,N) in enumerate(sample_sizes)
        L = lower_bound(stochasticmodel, sampler; solver = solver, N = N, M = 100, confidence = 1-α)
        intervals[i] = U-L
    end
    return intervals
end

sample_sizes = [10,100,500,1000]

ls = LShapedSolver(GurobiSolver(OutputFlag=0), subsolver = ()->GurobiSolver(OutputFlag=0), distributed = true, regularization = :tr, κ = 1.0, bundle = 2, log = false)

intervals = confidence_intervals(sample_sizes, ls)

open("confidence_intervals.csv", "w") do io
    writedlm(io, ["N" "Interval"], ',')
    writedlm(io, hcat(sample_sizes, intervals), ',')
end
sample_sizes = readdlm("confidence_intervals.csv", ',')[2:end,1]
intervals = readdlm("confidence_intervals.csv", ',')[2:end,2]
p = plot(sample_sizes, intervals,
         xlabel = "# Samples N",
         ylabel = "Confidence Interval Length",
         label = "Day-ahead planning problem",
         linewidth = 2,
         tickfontsize = 10,
         guidefontsize = 10,
         tickfontfamily = "sans-serif",
         guidefontfamily = "sans-serif")
savefig(p,"fig3.pdf")
