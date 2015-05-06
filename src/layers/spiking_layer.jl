

# constructs a spiking layer out of a parametric type, like HHNeuron
function SpikingLayer{T <: AbstractSpikingNeuron}(::Type{T}, name::ASCIIString, N::Int64)
	units = [T() for i=1:N]
	SpikingLayer(name,N,units)
end

function update!(layer::SpikingLayer{SimpleSpikingNeuron}, pres::Vector{SpikingConnection}, doSpike::BitArray{1}, t::Float64)
	for i=1:layer.N
		update!(layer.units[i], doSpike[i], t)
	end
end

function update!(layer::SpikingLayer{HHNeuron}, pres::Vector{SpikingConnection}, Iinj::Vector{Float64}, t::Float64)
	Ge_syn = zeros(layer.N)
	Gi_syn = zeros(layer.N)
	
#	@bp layer.name == "LGN_L"

	# integrate all synaptic conductances
	for sc in pres
		for syn in sc.synapses
			if syn.stype == EXC
				Ge_syn[syn.t] += syn.w * syn.g
			else
				Gi_syn[syn.t] += syn.w * syn.g
			end
		end
	end

	for i=1:layer.N
		update!(layer.units[i], Ge_syn[i], Gi_syn[i], Iinj[i], t)
	end
end

function update!(layer::SpikingLayer{HHNeuron}, pres::Vector{SpikingConnection}, Iinj::Nothing, t::Float64)
	update!(layer,pres,zeros(layer.N),t)
end

function didSpike(layer::SpikingLayer)
	[unit.didSpike for unit in layer.units]
end

function reset!(layer::SpikingLayer)
	for unit in layer.units
		reset!(unit)
	end
end