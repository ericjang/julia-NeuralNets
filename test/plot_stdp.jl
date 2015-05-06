using NeuralNets
using PyPlot


# also plot the weights
Δts = [-60:1:60] # in sec
return
plot(Δts,[stdp(Δt) for Δt in Δts])
ylabel("Δw")
xlabel("Δt = t_post-t_pre (ms)")
title("STDP curve")
grid()
println("Press Enter to Continue...")
readline()
