#!/bin/sh
./julia -e 'using Pkg; pkg"activate ."; include("benchmarks/bundle_scaling/bundle_8.jl")'
