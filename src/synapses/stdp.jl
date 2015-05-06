const LR = 0.0001
const dtau = 34 # sec
const ptau = 17 # sec

# is positive when Δt > 0
# note, this is defined on a ms scale
function stdp(Δt)
	# stdp function
    if Δt > 0
        return LR*exp(-Δt/ptau)
    elseif Δt < 0
        return -LR*exp(Δt/dtau)
    else # Δt=0, pre and post are simultaneous - no modification
        return 0
    end
end


# in the paper, t_pre = time when presynaptic cell activated
# t_post is when postsynaptic cell is activated. Therefore, Δt computed from 
# spike times, not last spike arrival time of pre
function updateSTDP!(syn::SpikingSynapse, source::AbstractSpikingNeuron, target::AbstractSpikingNeuron)
    if source.didSpike || target.didSpike
        syn.w += stdp(target.lastSpike - source.lastSpike)
        syn.w = max(0,syn.w) # make sure weights dont go negative
    end
end

