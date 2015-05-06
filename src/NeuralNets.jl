module NeuralNets

for (dir, filename) in [
	# CORE
	("","constants.jl"),
	("","types.jl"),
	# NEURON
	("neurons","simple_spiking.jl"),
	("neurons","hodgkin_huxley.jl"),
	# Synapses
	("synapses","spiking_synapse.jl"),
	("synapses","spiking_conn.jl"),
	("synapses","stdp.jl"),
	# Layers
	("layers","spiking_layer.jl"),
	# Network
	("nets","spiking_layers_net.jl"),
	("nets","small_net.jl"),
	# simulation
	("","run_results.jl"),
	# APMA2821V-specific codes
	("apma2821v","connectivities.jl"),
	("apma2821v","buildnet.jl"),
	("apma2821v","stimuli.jl")
	#("apma2821v","plotting.jl")
	]
	include(joinpath(dir, filename))
end

# NEURON
export HHNeuron, SimpleSpikingNeuron
# SYNAPSE
export SpikingSynapse, SynapseType, EXC, INH
export SpikingConnection, stdp
# LAYERS
export SpikingLayer, update!
# I/O
export RunSettings, RunResults
# NETWORKS
export SpikingLayersNet, add_layer!, connect!, runSpikingNet!, save, loadNet, resetLayers!, normalizeWeights!
# APMA2821V
export all_to_all, p_lgn_connectivity, forward_connectivity, lateral_connectivity
export buildnet
export image_stim
#export plot_all_rasters, plot_raster, plot_stim


end # module NeuralNets
