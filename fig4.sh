#!/bin/sh
./julia -e 'using Pkg; pkg"activate ."; include("benchmarks/ls_scaling/ls_1.jl")'
./julia -e 'using Pkg; pkg"activate ."; include("benchmarks/ls_scaling/ls_2.jl")'
./julia -e 'using Pkg; pkg"activate ."; include("benchmarks/ls_scaling/ls_4.jl")'
./julia -e 'using Pkg; pkg"activate ."; include("benchmarks/ls_scaling/ls_8.jl")'
./julia -e 'using Pkg; pkg"activate ."; include("benchmarks/ls_scaling/ls_16.jl")'
./julia -e 'using Pkg; pkg"activate ."; include("benchmarks/ls_scaling/compile.jl")'
