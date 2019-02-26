#!/bin/sh
./julia -e 'using Pkg; pkg"activate ."; include("general/confidence_intervals.jl")'
