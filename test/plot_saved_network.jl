# load simulated data
using NeuralNets
using HDF5, JLD
# reconstruct RunResults
results = load("trial1.jld","results")
include("../src/apma2821v/plotting.jl")
plot_vision_rasters(results)
println("Press [Enter] to continue...")
readline()