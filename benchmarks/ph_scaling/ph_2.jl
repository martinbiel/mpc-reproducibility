using Random
using DABenchmarks
using LaTeXStrings

Random.seed!(0)

using Distributed
addprocs(2, exeflags="--project")

@everywhere using StochasticPrograms
@everywhere using ProgressiveHedgingSolvers
@everywhere using HydroModels
@everywhere using Ipopt

function prepare_dbenchmark(nscenarios::Integer, nsamples::Integer; timeout::Integer = 1000)
    ph = ProgressiveHedgingSolver(()->IpoptSolver(print_level=0), execution = :synchronous, penalty = :adaptive, ζ = 0.01, α = 0.75, log = false, τ = 5e-6)
    solvers = [ph]
    solvernames = ["Synchronous progressive-hedging"]
    # Create Day-ahead benchmark
    return Scaling(solvernames, solvers, nscenarios, nsamples; timeout = timeout)
end
dab = prepare_dbenchmark(1000, 5); warmup_benchmarks!(dab); run_benchmarks!(dab); save_results!(dab, "ph_2.json")
exit()
