# Install (Julia 1.0.2)
using Pkg
pkg"activate ."
pkg"instantiate"
# Gurobi (requires license)
#pkg"add Gurobi"
pkg"precompile"
