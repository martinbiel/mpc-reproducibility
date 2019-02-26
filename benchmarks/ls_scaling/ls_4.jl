using Random
using DABenchmarks
using LaTeXStrings

Random.seed!(0)

using Distributed
addprocs(4, exeflags="--project")

@everywhere using StochasticPrograms
@everywhere using LShapedSolvers
@everywhere using HydroModels
@everywhere using GLPKMathProgInterface

function prepare_dbenchmark(nscenarios::Integer, nsamples::Integer; timeout::Integer = 1000)
    dls = LShapedSolver(GLPKSolverLP(), log=false, distributed = true, subsolver = ()->GLPKSolverLP(), κ=1.0)
    dtr = LShapedSolver(GLPKSolverLP(), regularization = :tr, log=false, distributed = true, subsolver = ()->GLPKSolverLP(), κ=1.0)
    solvers = [dls,dtr]
    solvernames = ["Distributed L-shaped","Distributed L-shaped with trust-region"]
    # Create Day-ahead benchmark
    return Scaling(solvernames, solvers, nscenarios, nsamples; timeout = timeout)
end
dab = prepare_dbenchmark(1000, 10); warmup_benchmarks!(dab); run_benchmarks!(dab); save_results!(dab, "ls_scaling_4.json")
exit()
