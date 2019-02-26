module DABenchmarks

using Distributed
using LShapedSolvers
using HydroModels
using BenchmarkTools
using RecipesBase
using LaTeXStrings
using Colors
using Statistics
using Colors
using Printf
using Logging

export
    DABenchmark,
    save_benchmark,
    load_benchmark,
    warmup_benchmarks!,
    run_benchmarks!,
    save_results!,
    load_results!,
    load_results,
    Sequential,
    Scaling

mutable struct DABenchmark{BType}
    names::Vector{String}
    benchmarks::BenchmarkGroup
    medians::Matrix{Float64}
    results::BenchmarkGroup

    function (::Type{DABenchmark})(names::Vector{String}, benchmarks::BenchmarkGroup, btype::Symbol)
        return new{btype}(names, benchmarks, zeros(length(names),1), BenchmarkGroup())
    end

    function (::Type{DABenchmark})(names::Vector{String}, benchmarks::BenchmarkGroup, results::BenchmarkGroup, btype::Symbol)
        return new{btype}(names, benchmarks, zeros(length(names),1), results)
    end
end

function Sequential(solvernames::Vector{String}, solvers::Vector, nscenarios::Integer, nsamples::Integer; timeout::Int = 100)
    length(solvernames) == length(solvers) || error("Inconsistent number of solvernames/solvers")
    benchmarks = BenchmarkGroup(solvernames)
    for (solvername, solver) in zip(solvernames, solvers)
        solve_time = @elapsed begin
            da = load_model(nscenarios)
            plan!(da, optimsolver = solver)
        end
        max_time = min((nsamples+1)*solve_time, timeout)
        benchmarks[solvername] = @benchmarkable plan!(da,optimsolver=$solver) seconds=max_time samples=nsamples setup=(da = load_model($nscenarios))
    end
    dab = DABenchmark(solvernames, benchmarks, :seq)
    return dab
end

function Scaling(solvernames::Vector{String}, solvers::Vector, nscenarios::Integer, nsamples::Integer; timeout::Int = 1000)
    length(solvernames) == length(solvers) || error("Inconsistent number of solvernames/solvers")
    benchmarks = BenchmarkGroup()
    b = benchmarks[string(nworkers())] = BenchmarkGroup(solvernames)
    for (solvername, solver) in zip(solvernames, solvers)
        solve_time = @elapsed begin
            da = load_model(nscenarios)
            plan!(da, optimsolver = solver)
        end
        max_time = min((nsamples+1)*solve_time, timeout)
        b[solvername] = @benchmarkable plan!(da,optimsolver=$solver) seconds=max_time samples=nsamples setup=(da = load_model($nscenarios))
    end
    dab = DABenchmark(solvernames, benchmarks, :scaling)
    return dab
end

function load_model(nscenarios::Integer)
    dayahead_data = HydroModels.NordPoolDayAheadData("data/plantdata.csv", "data/spotprices.csv", 1, 35.0, 60.0)
    sampler = DayAheadSampler(dayahead_data)
    dayahead_model = DayAheadModel(dayahead_data, sampler, nscenarios, [:Skellefteälven])
    return dayahead_model
end

function collect_estimates!(da_benchmark::DABenchmark{:seq})
    medians = time(median(da_benchmark.results))
    da_benchmark.medians = zeros(length(da_benchmark.names))
    for (j,solvername) in enumerate(da_benchmark.names)
        da_benchmark.medians[j] = medians[solvername] / 1e9
    end
end

function collect_estimates!(da_benchmark::DABenchmark{:scaling})
    medians = time(median(da_benchmark.results))
    nworkers = sort(parse.(Int, keys(da_benchmark.results)))
    da_benchmark.medians = zeros(length(keys(da_benchmark.results)), length(da_benchmark.names))
    for (i,w) in enumerate(nworkers)
        for (j,solvername) in enumerate(da_benchmark.names)
            da_benchmark.medians[i,j] = medians[string(w)][solvername] / 1e9
        end
    end
end

function collect_estimates!(da_benchmark::DABenchmark{:async})
    medians = time(median(da_benchmark.results))
    κs = sort(parse.(Float64, keys(da_benchmark.results[first(da_benchmark.names)])))
    da_benchmark.medians = zeros(length(da_benchmark.names), length(κs))
    for (i,solvername) in enumerate(da_benchmark.names)
        for (j,κ) in enumerate(κs)
            da_benchmark.medians[i,j] = medians[solvername][string(κ)] / 1e9
        end
    end
end

function collect_estimates!(da_benchmark::DABenchmark{:bundle})
    medians = time(median(da_benchmark.results))
    bundles = sort(parse.(Int, keys(da_benchmark.results[first(da_benchmark.names)])))
    da_benchmark.medians = zeros(length(da_benchmark.names), length(bundles))
    for (i,solvername) in enumerate(da_benchmark.names)
        for (j,b) in enumerate(bundles)
            da_benchmark.medians[i,j] = medians[solvername][string(b)] / 1e9
        end
    end
end

function save_benchmark(da_benchmark::DABenchmark, filename::String)
    BenchmarkTools.save(filename, da_benchmark.benchmarks)
end

function load_benchmark(filename::String)
    benchmarks = BenchmarkTools.load(filename)
    solvernames::Vector{String} = collect(keys(first(benchmarks)))
    da_benchmark = DABenchmark(solvernames,benchmarks)
    return da_benchmark
end

function warmup_benchmarks!(da_benchmark::DABenchmark)
    warmup(da_benchmark.benchmarks)
    nothing
end

function run_benchmarks!(da_benchmark::DABenchmark)
    da_benchmark.results = run(da_benchmark.benchmarks, verbose=true)
    collect_estimates!(da_benchmark)
    return da_benchmark.results
end

function save_results!(da_benchmark::DABenchmark, filename::String)
    BenchmarkTools.save(filename, da_benchmark.results)
    nothing
end

function load_results!(da_benchmark::DABenchmark, filename::String)
    da_benchmark.results = BenchmarkTools.load(filename)[1]
    collect_estimates!(da_benchmark)
    return da_benchmark.results
end

function load_results(filename::String, ::Val{:async}) where btype
    results = BenchmarkTools.load(filename)[1]
    solvernames::Vector{String} = collect(keys(results))
    da_benchmark = DABenchmark(solvernames,BenchmarkGroup(), :async)
    load_results!(da_benchmark, filename)
    return da_benchmark
end

function load_results(filename::String, ::Val{:bundle}) where btype
    results = BenchmarkTools.load(filename)[1]
    solvernames::Vector{String} = collect(keys(results))
    da_benchmark = DABenchmark(solvernames,BenchmarkGroup(), :bundle)
    load_results!(da_benchmark, filename)
    return da_benchmark
end

function load_results(filename::String, ::Val{btype}) where btype
    results = BenchmarkTools.load(filename)[1]
    solvernames::Vector{String} = collect(keys(first(values(results))))
    da_benchmark = DABenchmark(solvernames,BenchmarkGroup(),btype)
    load_results!(da_benchmark, filename)
    return da_benchmark
end

KTH_colors = [RGB(25/255,84/255,166/255),
              RGB(157/255,16/255,45/255),
              RGB(98/255,146/255,46/255),
              RGB(36/255,160/255,216/255),
              RGB(228/255,54/255,62/255),
              RGB(176/255,201/255,43/255),
              RGB(216/255,84/255,151/255),
              RGB(250/255,185/255,25/255),
              RGB(101/255,101/255,108/255),
              RGB(189/255,188/255,188/255),
              RGB(227/255,229/255,227/255)]

@recipe function f(benchmark::DABenchmark{:scaling})
    nworkers = sort(parse.(Int, keys(benchmark.results)))
    increment = std(benchmark.medians)
    tmin = 0.9*minimum(benchmark.medians)
    tmax = 1.05*maximum(benchmark.medians)

    linewidth --> 2
    tickfontsize := 10
    tickfontfamily := "sans-serif"
    guidefontsize := 10
    guidefontfamily := "sans-serif"
    legend := :topright
    xticks := sort(nworkers)
    xlabel := "Number of Cores P"
    ylabel := "Computation Time T [s]"
    ylims --> (tmin,tmax)
    yticks --> tmin:increment:tmax
    yformatter := (d) -> @sprintf("%.1f",d)
    color_palette := KTH_colors

    for (i,solver) in enumerate(benchmark.names)
        @series begin
            label --> solver
            nworkers, benchmark.medians[:,i]
        end
    end
end

@recipe function f(benchmark::DABenchmark{:async})
    κs = sort(parse.(Float64, keys(benchmark.results[first(benchmark.names)])))
    increment = std(benchmark.medians)
    tmin = 0.9*minimum(benchmark.medians)
    tmax = 1.05*maximum(benchmark.medians)

    linewidth --> 2
    tickfontsize := 10
    tickfontfamily := "sans-serif"
    guidefontsize := 10
    guidefontfamily := "sans-serif"
    legend := :topright
    xticks := sort(κs)
    xlabel := L"\kappa"
    ylabel := "Computation Time T [s]"
    ylims --> (tmin,tmax)
    yticks --> tmin:increment:tmax
    yformatter := (d) -> @sprintf("%.1f",d)
    color_palette := KTH_colors

    for (i,solver) in enumerate(benchmark.names)
        @series begin
            label --> solver
            κs, benchmark.medians[i,:]
        end
    end
end

@recipe function f(benchmark::DABenchmark{:bundle})
    bundles = sort(parse.(Int, keys(benchmark.results[first(benchmark.names)])))
    increment = std(benchmark.medians)
    tmin = 0.9*minimum(benchmark.medians)
    tmax = 1.05*maximum(benchmark.medians)

    linewidth --> 2
    tickfontsize := 10
    tickfontfamily := "sans-serif"
    guidefontsize := 10
    guidefontfamily := "sans-serif"
    legend := :topright
    xticks := sort(bundles)
    xlabel := "# Cuts in Bundle B"
    ylabel := "Computation Time T [s]"
    ylims --> (tmin,tmax)
    yticks --> tmin:increment:tmax
    yformatter := (d) -> @sprintf("%.1f",d)
    color_palette := KTH_colors

    for (i,solver) in enumerate(benchmark.names)
        @series begin
            label --> solver
            bundles, benchmark.medians[i,:]
        end
    end
end

end#module
