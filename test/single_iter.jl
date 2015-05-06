# Generic Spiking Layer driving an HH layer

# verifies that identical stimulus presented to 2 disconnected cells produces exactly the same datas
tic();

using Base.Test
using NeuralNets

N_stim = 100 # input dim
T = 300
dt = NeuralNets.dt

net = buildnet()

spike_train = image_stim("../images/021108_spasticroomjpg_1_.jpg", int(sqrt(N_stim)), T, dt)
stim_spikes = cell(length(net.l))
for li=1:length(net.l)
	if li in 1:3
		stim_spikes[li] = spike_train[:,:,li]
	else
		stim_spikes[li] = nothing
	end
end
rs = RunSettings(T,stim_spikes)

out = runSpikingNet!(net,rs)
# save out the data
using HDF5, JLD
save("trial1.jld","results",out)

toc()

# PROFILING
# rs.T = dt # single iteration to compile it
# println("Initial Compilation using JIT...")
# out = runSpikingNet!(net,rs)
# println("Profiling Network Simulation...")
# rs.T = T
# Profile.clear()
# @profile out = runSpikingNet!(net,rs)
# using ProfileView
# #Profile.init(1_000_000, 1)
# ProfileView.view()