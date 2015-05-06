# this implements a very simple spiking layer mechanism - it simply emits a single spike when input > 0
# common use case: drives actual biophysical layers in a heterogenous network with a source of spikes
# For now, this completely ignores incoming synaptic inputs (efficiency reasons)

function reset!(neuron::SimpleSpikingNeuron)
    neuron.lastSpike = -Inf
    neuron.didSpike = false
end

# type signature of update function should match others for operator overloading
# this is because simplespiking might not be a source layer (for whatever reason)
function update!(neuron::SimpleSpikingNeuron, doSpike::Bool, t::Float64)
	neuron.didSpike = doSpike
	if (doSpike)
		neuron.lastSpike = t
	end
end
