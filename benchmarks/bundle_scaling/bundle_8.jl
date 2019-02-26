using Random
using DABenchmarks

Random.seed!(0)

using Distributed
addprocs(8, exeflags="--project")

@everywhere using StochasticPrograms
@everywhere using LShapedSolvers
@everywhere using HydroModels
@everywhere using GLPKMathProgInterface

function prepare_dbenchmark(nscenarios::Integer, nsamples::Integer; timeout::Integer = 1000)
    dtr_1 = LShapedSolver(GLPKSolverLP(), regularization = :tr, log=false, distributed = true, subsolver = ()->GLPKSolverLP(), κ=1.0, bundle = 1)
    dtr_10 = LShapedSolver(GLPKSolverLP(), regularization = :tr, log=false, distributed = true, subsolver = ()->GLPKSolverLP(), κ=1.0, bundle = 10)
    dtr_50 = LShapedSolver(GLPKSolverLP(), regularization = :tr, log=false, distributed = true, subsolver = ()->GLPKSolverLP(), κ = 1.0, bundle = 50)
    dtr_100 = LShapedSolver(GLPKSolverLP(), regularization = :tr, log=false, distributed = true, subsolver = ()->GLPKSolverLP(), κ = 1.0, bundle = 100)
    dtr_125 = LShapedSolver(GLPKSolverLP(), regularization = :tr, log=false, distributed = true, subsolver = ()->GLPKSolverLP(), κ=1.0, bundle = 125)
    solvers = [dtr_1, dtr_10, dtr_50, dtr_100, dtr_125]
    solvernames = ["1", "10", "50", "100", "125"]
    # Create Day-ahead benchmark
    return Scaling(solvernames, solvers, nscenarios, nsamples; timeout = timeout)
end
dab = prepare_dbenchmark(1000, 10); warmup_benchmarks!(dab); run_benchmarks!(dab); save_results!(dab, "tr_bundle_8.json")
exit()
