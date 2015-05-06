# synaptic transmission

# allow SpikingConnection to be created before declaring source and target
# layers. Those values are initialized at runtime.
function SpikingConnection(synapses::Vector{SpikingSynapse}, stdp_enabled::Bool)
	w_avg = sum([syn.w for syn in synapses])/length(synapses)
	SpikingConnection(-1,-1,synapses,stdp_enabled, w_avg)
end

# not sure if separating updateSTDP! from stdp is slower or faster
function update!(sc::SpikingConnection, source_layer::AbstractSpikingLayer)
	for syn in sc.synapses
		update!(syn, source_layer.units[syn.s])
	end
end

# parallel version
function update!(sc_arr::Vector{SpikingConnection}, source_layer::AbstractSpikingLayer)
	for sc in sc_arr
		for syn in sc.synapses
			update!(syn, source_layer.units[syn.s])
		end
	end
end

# updates all synapses in a given connection
function updateSTDP!(sc::SpikingConnection, source_layer::AbstractSpikingLayer, post_layer::AbstractSpikingLayer)
	for syn in sc.synapses
		updateSTDP!(syn, source_layer.units[syn.s], post_layer.units[syn.t])
	end
end

# re-scales all synaptic weights so that average weights are maintained
function normalizeWeights!(sc::SpikingConnection)
	if sc.stdp_enabled # if stdp is disabled, weight modification cannot occur
		target_avg = sc.avg
		empirical_avg = sum([syn.w for syn in sc.synapses])/length(sc.synapses)
		for syn in sc.synapses
			syn.w *= target_avg/empirical_avg
		end
	end
end