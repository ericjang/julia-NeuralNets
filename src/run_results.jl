
# container variable for storing the results of simulations

function RunResults(net::SpikingLayersNet, settings::RunSettings)
    # storage for measurement variables
    # expressions for each layer
    T = settings.T
    names = Dict{Int64, ASCIIString}()
    N = Dict{Int64, Int64}()
    spikes = Dict{Int64, Vector{(Int64,Int64)}}()

    for (i,layer) in enumerate(net.l)
        names[i] = layer.name
        N[i] = layer.N
        spikes[i] = Array((Int64,Int64),0)
    end
    RunResults(names,N,spikes,dt,T)
end

function recordSpikes!(rec::RunResults, net::SpikingLayersNet, istep::Int64)
    for (i,layer) in enumerate(net.l)
        for ineuron in find(didSpike(layer))
            push!(rec.spikes[i], (istep,ineuron))
        end
    end
end

