using Random
using DABenchmarks
using LaTeXStrings

Random.seed!(0)

using Gurobi
using LShapedSolvers

function prepare_dbenchmark(nscenarios::Integer, nsamples::Integer; timeout::Integer = 1000)
    dls = LShapedSolver(GurobiSolver(OutputFlag=0), log=false)
    dtr = LShapedSolver(GurobiSolver(OutputFlag=0), regularization = :tr, log=false)
    solvers = [dls,dtr]
    solvernames = ["Distributed L-shaped","Distributed L-shaped with trust-region"]
    # Create Day-ahead benchmark
    return Scaling(solvernames, solvers, nscenarios, nsamples; timeout = timeout)
end
dab = prepare_dbenchmark(1000, 10); warmup_benchmarks!(dab); run_benchmarks!(dab); save_results!(dab, "ls_scaling_1.json")
exit()
