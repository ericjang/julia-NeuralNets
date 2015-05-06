# Generic Spiking Layer driving an HH layer

# verifies that identical stimulus presented to 2 disconnected cells produces exactly the same datas

using NeuralNets

N_stim = 100 # input dim
T = 300
dt = 0.01
time_trace = 0:dt:T
nsteps = length(time_trace)

net = SpikingLayersNet()

# create layers
P_L = add_layer!(net, SpikingLayer(SimpleSpikingNeuron,"P_L",100))
LGN_L = add_layer!(net, SpikingLayer(HHNeuron,"LGN_L",900))
c = p_lgn_connectivity(P_L.N, LGN_L.N, EXC, 3, false)
connect!(net, "P_L", "LGN_L", c)

# precompute image stimulus
spike_train = falses(N_stim,nsteps,3)
for i=1:N_stim	
	input_freq = 30 + 10 * rand()
	ISI = int(round(1/input_freq * 1000/dt))# in steps 
	spike_train[i,1:ISI:end,1] = true
end

stim_spikes = cell(length(net.l))
stim_spikes[1] = spike_train[:,:,1]
stim_spikes[2] = nothing
rs = RunSettings(T,stim_spikes)
out = runSpikingNet!(net,rs)


using PyPlot
include("../src/apma2821v/plotting.jl")
plot_all_rasters(out)
println("Press Enter to Continue...")
readline()

