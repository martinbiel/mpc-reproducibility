Reproducing results for #022019-00008
==============================================================

This document describes the dependencies and experimental setup used to generate the numerical results presented in the paper #022019-00008, submitted for possible publication in [Mathematical Programming Computation](https://link.springer.com/journal/12532). Specifically, the generation of Fig. 2 - Fig. 6 is outlined to an extent where it should be possible to reproduce the results, assuming similar hardware is available. The dependencies can either be installed by following the instructions outlined here, or by mounting a predefined docker file.

Description
-----------

### Meta information

-   **Program: Julia**

-   **Data set: `plantdata.csv`, `spotprices.csv`**

-   **Run-time environment: Archlinux**

-   **Hardware: Master: 4-core machine, Workers: 32-core machine**

-   **Execution: Serial, Parallel**

-   **Output: General results and benchmarks of distributed solvers**

-   **Publicly available: [Github](https://github.com/martinbiel)**

### How software can be obtained

All implemented code is available freely on
[Github](https://github.com/martinbiel):

-   StochasticPrograms.jl: https://github.com/martinbiel/StochasticPrograms.jl

-   LShapedSolvers.jl: https://github.com/martinbiel/LShapedSolvers.jl

-   ProgressiveHedgingSolvers.jl: https://github.com/martinbiel/ProgressiveHedgingSolvers.jl

-   TraitDispatch.jl: https://github.com/martinbiel/TraitDispatch.jl

-   HydroModels.jl: https://github.com/martinbiel/HydroModels.jl

The most convenient approach for reproducing results is to fetch the
modules directly into Julia, as shown in the installation section below.

### Hardware dependencies

The numerical experiments were performed on a laptop computer (4 processing cores in total) and a server node (32 processing
cores in total) with the following specifications.

-   **Processor:** Master: One Intel Core I7-4600U (Dual Core, 2.60GHz), Workers: Two Intel Xeon E5-2687W (Eight Core, 3.10GHz Turbo)

-   **Memory:** Master: 16GB 1600MHz DDR3L, Workers: 128GB (16x8GB) 1600MHz DDR3 ECC RDIMM

### Software dependencies

-   Julia v1.0.2

-   Python 3.6.6 with matplotlib 2.2.2

-   Gurobi 7.0.2

-   Docker (optionally)

### Datasets

Two datasets were used. First, `plantdata.csv` contains physical specifications for the hydroplants in the river Skellefteälven. This was first published in the following [Master thesis](http://kth.diva-portal.org/smash/record.jsf?pid=diva2%3A1215858&dswid=8071), in Table 1 and Table 2. Second, `spotprices.csv` should contain the hourly market price of electricity in the region during 2017. This data is available on [NordPool](https://www.nordpoolgroup.com/globalassets/marketdata-excel-files/elspot-prices_2017_hourly_eur.xls). Note, that line 2022 has no price data. Either remove this line or interpolate from the surrounding data. Alternatively, the `spotprices.csv` in this repository contains dummy data that can be used instead.

Installation (Manual)
------------

The numerical experiments were performed on Julia version v1.0.2, available on [Github](https://github.com/JuliaLang/julia/releases/tag/v1.0.2). For
best performance, it is recommended to build Julia from source, according to the instructions at the [Julia Github page](https://github.com/JuliaLang/julia#source-download-and-compilation). The required Julia packages are installed by running the script `install.jl`. This fetches and installs all necessary packages, including the packages made by the paper authors. Alternatively, the script `install.sh` fetches the generic binaries of Julia 1.0.2 and then runs the same installation procedure. The automatic installation procedures requires Gurobi to be properly installed first (see below). The Julia environment used should work on most Linux distributions. Note, that the automatic procedure precompiles a large fraction of the code after installation, so the full procedure should be expected to take 5-10 minutes to complete.

The plots in the paper were drawn using the PyPlot backend, which requires matplotlib to be installed.

All results in this work were generated using Gurobi version 7.0.2, which needs to be installed separately along with a valid license. Gurobi has free licenses available for academic users. If a Gurobi installation is available, and the environment variables `$GUROBI_HOME` and `$GRB_LICENCE_FILE` are set to the source folder and licence file location respectively, then Gurobi can be installed in Julia as follows:

```julia
using Pkg
pkg"add Gurobi"

```

The Julia wrapper of Gurobi will be installed during the automatic `install.jl` procedure, assuming Gurobi is installed and the environmental variables are set. See the notes at the end of this document for more information.

Installation (Docker)
------------

A docker image with all necessary binaries is available named `mbiel/mpc-reproducibility`. To use it, install docker. Next, run

```
docker run --interactive --tty mbiel/mpc-reproducibility
```

After fetching the binaries a Julia prompt with all necessary libraries should appear, and one can proceed to follow the instructions outline here. Note, that it is not possible to redistribute Gurobi in docker, so the premade environment uses GLPK and Ipopt instead. See the notes at the end of this document for a discussion of the consequences of this. There is no GUI backend in docker, so plots will not actually be displayed. Figures can still be saved as pdfs through `savefig(plot(X),"X.pdf")`. The result benchmarks can be loaded and compared to new benchmarks directly in the Julia prompt as well.

Experiment workflow
-------------------

The Julia environment used during the experiments is exactly described in the provided `Project.toml` and `Manifest.toml` files, using Julias package manager. While in the same folder as these files, run

```julia
using Pkg
pkg"activate ."

```

to acquire the same Julia environment, including correct versions of each Julia package used. Many of the computations are distributed. When the paper results were produced, the master node was a laptop computer and workers were spawned on a remote server. Some files must be configured if other worker configurations are to be used. Specifically, the following lines must be configured:

```julia
using Distributed
machine = [("MACHINENAME", X)]
addprocs(machine, dir = "/home/USER", exename="/path/to/julia", exeflags="--project")

```

Here, `"MACHINENAME"` must be some remote alias accesible from the master node, `X` is the number of workers to spawn, `"/home/USER"` must be a folder on the worker nodes that contains the `Project.toml` and `Manifest.toml` files included in this repository, and the `/path/to/julia` must point to a Julia 1.0.2 binary location on the worker node. Alternatively, `addprocs(X, exeflags="--project")` spawns `X` workers locally.

Fig. 2 and Fig. 3 are generated by the files included in the `general` folder. The remaining results are benchmarks, which each have their own folders. The file `plotresults.jl` will create Fig. 4 - Fig. 6 after the benchmarks have been run. The necessary steps to reproduce the results are outlined below.

### Fig. 2

Fig. 2 illustrates convergence for the farmer problem when applying the implemented L-shaped and progressive-hedging methods. The results are reproduced by running the `farmer.jl` in the `general` folder. This is conveniently run from the top folder using

```julia
using Pkg
pkg"activate ."
include("general/farmer.jl")

```

in a Julia session. Alternatively, run `fig2.sh` from the top folder. The result is two pdf files, `farmer_ls.pdf` and `farmer_ph.pdf` which were combined to create Fig. 2.

### Fig. 3

Fig. 3 illustrates confidence intervals as a function of sample size for the day-ahead problem described in the paper. This calculation takes a considerable amount of time, but was sped up by running in parallel on 28 worker cores. If worker cores are not available, the `general/confidence_intervals.jl` must be changed accordingly. Long computation times are expected if this script is run in a single core setting. The script is conveniently run from the top folder using

```julia
using Pkg
pkg"activate ."
include("general/confidence_intervals.jl")

```

in a Julia session. Alternatively, run `fig3.sh` from the top folder.

### Fig. 4

Fig. 4 is a strong scaling plot of distributed L-shaped solvers applied to the day-ahead problem described in the paper. It is generated by running several Julia scripts, which benchmark the problem for various number of workers. These scripts are located in the `benchmarks/ls_scaling` folder and are named `ls_X.jl` where `X` is the number of workers. These scripts must be changed to point to the correct remote machine for worker spawning, or simply spawn all workers on the same machine. The `compile.jl` script located in the same folder combines all results into one `csv` file. The most convenient way to repeat the experiment is to run the `fig4.sh` script from the top folder. The result is the file `ls_scaling.json`, which can be compared to the one generated in the paper in the `benchmark_results` folder. The `plotresults.jl` script can be used to generate Fig. 4

### Fig. 5

Fig. 5 illustrates computation time as a function of bundle size when applying a distributed L-shaped solver to the day-ahead problem described in the paper. It is generated by running the script `benchmarks/bundle_scaling/bundle_8.jl`. The experiment was run using 8 worker cores. The scripts must be changed to point to the correct remote machine for worker spawning, or simply spawn all workers on the same machine. The most convenient way to repeat the experiment is to run the `fig5.sh` script from the top folder. The result is the file `tr_bundle_8.json`, which can be compared to the one generated in the paper in the `benchmark_results` folder. The `plotresults.jl` script can be used to generate Fig. 5

### Fig. 6

Fig. 6 is a strong scaling plot of distributed progressive-hedging solvers applied to the day-ahead problem described in the paper. It is generated by running several Julia scripts, which benchmark the problem for various number of workers. These scripts are located in the `benchmarks/ph_scaling` folder and are named `ph_X.jl` where `X` is the number of workers. These scripts must be changed to point to the correct remote machine for worker spawning, or simply spawn all workers on the same machine. The `compile.jl` script located in the same folder combines all results into one `csv` file. The most convenient way to repeat the experiment is to run the `fig6.sh` script from the top folder. The result is the file `ph_scaling.json`, which can be compared to the one generated in the paper in the `benchmark_results` folder. The `plotresults.jl` script can be used to generate Fig. 6.


Notes
-----

If a Gurobi license is not available, the open-source solvers GLPK and Ipopt could be used as a subsolver instead. This yields a
significant decrease in performance, so the presented computational results are not expected to be reproduced. This also requires running

```julia
using Pkg
pkg"activate ."
pkg"rm Gurobi"
pkg"add https://github.com/martinbiel/LShapedSolvers.jl#mpc-submission-docker"

```

to remove the Gurobi dependency, before running the `install.jl` script. The `docker` branch of this repository contains versions of all files that are independent of a Gurobi installation.
