using Random
using DABenchmarks
using LaTeXStrings

Random.seed!(0)

using Distributed
machine = [("MACHINENAME", 4)]
addprocs(machine, dir = "/home/USER", exename="/path/to/julia", exeflags="--project")
# addprocs(4, exeflags="--project") # For local workers

@everywhere using StochasticPrograms
@everywhere using ProgressiveHedgingSolvers
@everywhere using HydroModels
@everywhere using Gurobi

function prepare_dbenchmark(nscenarios::Integer, nsamples::Integer; timeout::Integer = 1000)
    ph = ProgressiveHedgingSolver(()->GurobiSolver(OutputFlag=0), execution = :synchronous, penalty = :adaptive, ζ = 0.01, α = 0.75, log = false, τ = 5e-6)
    solvers = [ph]
    solvernames = ["Synchronous progressive-hedging"]
    # Create Day-ahead benchmark
    return Scaling(solvernames, solvers, nscenarios, nsamples; timeout = timeout)
end
@info "Running progressive-hedging benchmarks on 4 workers..."
dab = prepare_dbenchmark(1000, 5); warmup_benchmarks!(dab); run_benchmarks!(dab); save_results!(dab, "ph_4.json")
exit()
