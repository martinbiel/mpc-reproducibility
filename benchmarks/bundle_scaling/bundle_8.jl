using Random
using DABenchmarks

Random.seed!(0)

using Distributed
machine = [("MACHINENAME", 8)]
addprocs(machine, dir = "/home/USER", exename="/path/to/julia", exeflags="--project")
# addprocs(8, exeflags="--project") # For local workers

@everywhere using StochasticPrograms
@everywhere using LShapedSolvers
@everywhere using HydroModels
@everywhere using Gurobi

function prepare_dbenchmark(nscenarios::Integer, nsamples::Integer; timeout::Integer = 1000)
    dtr_1 = LShapedSolver(GurobiSolver(OutputFlag=0), regularization = :tr, log=false, distributed = true, subsolver = ()->GurobiSolver(OutputFlag=0), κ=1.0, bundle = 1)
    dtr_10 = LShapedSolver(GurobiSolver(OutputFlag=0), regularization = :tr, log=false, distributed = true, subsolver = ()->GurobiSolver(OutputFlag=0), κ=1.0, bundle = 10)
    dtr_50 = LShapedSolver(GurobiSolver(OutputFlag=0), regularization = :tr, log=false, distributed = true, subsolver = ()->GurobiSolver(OutputFlag=0), κ = 1.0, bundle = 50)
    dtr_100 = LShapedSolver(GurobiSolver(OutputFlag=0), regularization = :tr, log=false, distributed = true, subsolver = ()->GurobiSolver(OutputFlag=0), κ = 1.0, bundle = 100)
    dtr_125 = LShapedSolver(GurobiSolver(OutputFlag=0), regularization = :tr, log=false, distributed = true, subsolver = ()->GurobiSolver(OutputFlag=0), κ=1.0, bundle = 125)
    solvers = [dtr_1, dtr_10, dtr_50, dtr_100, dtr_125]
    solvernames = ["1", "10", "50", "100", "125"]
    # Create Day-ahead benchmark
    return Scaling(solvernames, solvers, nscenarios, nsamples; timeout = timeout)
end
@info "Running bundled L-shaped benchmarks on 16 workers..."
dab = prepare_dbenchmark(1000, 10); warmup_benchmarks!(dab); run_benchmarks!(dab); save_results!(dab, "tr_bundle_8.json")
exit()
