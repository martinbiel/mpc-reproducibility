using Random
using DABenchmarks
using LaTeXStrings

Random.seed!(0)

using Ipopt
using ProgressiveHedgingSolvers

function prepare_dbenchmark(nscenarios::Integer, nsamples::Integer; timeout::Integer = 1000)
    ph = ProgressiveHedgingSolver(()->IpoptSolver(print_level=0), penalty = :adaptive, ζ = 100, log = false, τ = 1e-5)
    solvers = [ph]
    solvernames = ["Synchronous progressive-hedging"]
    # Create Day-ahead benchmark
    return Scaling(solvernames, solvers, nscenarios, nsamples; timeout = timeout)
end
dab = prepare_dbenchmark(1000, 5); warmup_benchmarks!(dab); run_benchmarks!(dab); save_results!(dab, "ph_1.json")
exit()
