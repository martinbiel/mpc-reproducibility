using Random
using DABenchmarks
using LaTeXStrings

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
    dls = LShapedSolver(GurobiSolver(OutputFlag=0), log=false, distributed = true, subsolver = ()->GurobiSolver(OutputFlag=0), κ=1.0)
    dtr = LShapedSolver(GurobiSolver(OutputFlag=0), regularization = :tr, log=false, distributed = true, subsolver = ()->GurobiSolver(OutputFlag=0), κ=1.0)
    solvers = [dls,dtr]
    solvernames = ["Distributed L-shaped","Distributed L-shaped with trust-region"]
    # Create Day-ahead benchmark
    return Scaling(solvernames, solvers, nscenarios, nsamples; timeout = timeout)
end
@info "Running L-shaped benchmarks on 8 workers..."
dab = prepare_dbenchmark(1000, 10); warmup_benchmarks!(dab); run_benchmarks!(dab); save_results!(dab, "ls_scaling_8.json")
exit()
