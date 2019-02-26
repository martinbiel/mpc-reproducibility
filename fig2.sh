#!/bin/sh
./julia -e 'using Pkg; pkg"activate ."; include("general/farmer.jl")'
