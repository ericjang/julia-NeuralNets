
using Graphs

abstract AbstractSpikingNeuron
abstract AbstractSpikingLayer
abstract AbstractConnection
abstract AbstractNet


type SimpleSpikingNeuron <: AbstractSpikingNeuron
	lastSpike::Float64
    didSpike::Bool
    function SimpleSpikingNeuron()
    	new(-Inf,false)
	end
end

type HHNeuron <: AbstractSpikingNeuron
	m::Float64 # Na channel activation
	h::Float64 # Na channel inactivation
	n::Float64 # K channel activation
	v::Float64 # membrane potential
	lastSpike::Float64 # time of last spike
	didSpike::Bool
end

typealias SynapseType Int64
const EXC = 1
const INH = 2


type SpikingSynapse
	stype::SynapseType
	s::Int64 # source index
	t::Int64 # target index
	w::Float64 # weight
	d::Float64 # delay
	g::Float64 # transmitted conductance
	tau::Float64 # synaptic time constant
	incoming::Vector{Bool}
	_head::Int64
	_ql::Int64
end


type SpikingLayer{T <: AbstractSpikingNeuron} <: AbstractSpikingLayer
	name::ASCIIString
	N::Int64
	units::Vector{T}
end

type SpikingConnection <: AbstractConnection
	s::Int64 # source layer index (pre)
	t::Int64 # target layer index (post)
	synapses::Vector{SpikingSynapse}
	stdp_enabled::Bool
	avg::Float64 # average weight of all synapses
end

type RunSettings
    T # time 
    stim_spikes::Vector{Any} # dense matrix or nothing
    # stim_inj::Dict{Int64,Array{Float64,2}}
#    stim::Function  # input(a,b,c) = a'th neuron at timestep b, layer c
end

type RunResults
    names::Dict{Int64, ASCIIString}
    N::Dict{Int64, Int64}
    spikes::Dict{Int64, Vector{(Int64,Int64)}} # sparse spike arrays = time, index
    # pre_init::Vector{Vector{SpikingConnection}} # initial synapses & weights
    # pre_end::Vector{Vector{SpikingConnection}} # final synapses & weights
    dt::Float64
    T::Float64
end

# for building smaller, simple networks
# no concept of layers, just neurons wired together in a small graph.
type SpikingNet <: AbstractNet
	g::SimpleGraph
	l::Vector{AbstractSpikingLayer}
	synapses::Vector{SpikingSynapse}
	stdp_enabled::Bool
end

type SpikingLayersNet <: AbstractNet
    g::SimpleGraph # we don't actually use this graph for anything... except maybe drawing?
    l::Vector{AbstractSpikingLayer} # layers, represented by each node
    # SpikingConnection in pre and post are modified by reference!
    pre::Vector{Vector{SpikingConnection}} # presynaptic synapses for each layer
    post::Vector{Vector{SpikingConnection}} # postsynaptic synapses for each layer
end
