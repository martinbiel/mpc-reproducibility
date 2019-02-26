#!/bin/sh
./julia -e 'using Pkg; pkg"activate ."; include("benchmarks/ph_scaling/ph_1.jl")'
./julia -e 'using Pkg; pkg"activate ."; include("benchmarks/ph_scaling/ph_2.jl")'
./julia -e 'using Pkg; pkg"activate ."; include("benchmarks/ph_scaling/ph_4.jl")'
./julia -e 'using Pkg; pkg"activate ."; include("benchmarks/ph_scaling/ph_8.jl")'
./julia -e 'using Pkg; pkg"activate ."; include("benchmarks/ph_scaling/ph_16.jl")'
./julia -e 'using Pkg; pkg"activate ."; include("benchmarks/ph_scaling/compile.jl")'
