# initialize incoming spikes queue for each synapse

using ProgressMeter
using HDF5, JLD

function SpikingLayersNet()
    g = simple_graph(0)
    # I don't think Julia can create empty sparse matrices of arbitrary type
    # that can be flexibly resized...
    SpikingLayersNet(g,AbstractSpikingLayer[], Vector{SpikingConnection}[], Vector{SpikingConnection}[])
end

## Loading

function save(net::SpikingLayersNet, filename::ASCIIString)
    # saves the weights and state of the network
    save(filename,"net",net)
end

function loadNet(filename::ASCIIString)
    d = load(filename)
    d["net"]
end

# CONNECTING

function addSpikingConnection!(net::SpikingLayersNet, c::SpikingConnection)
    # TODO - this currently adds another synapse. need flag to 
    # specify whether to overwrite an existing connection
    if c.s == 0
        error("Presynaptic layer not specified")
    end
    if c.t == 0
        error("Postsynaptic layer not specified")
    end
    add_edge!(net.g,c.s,c.t)
    push!(net.post[c.s],c)
    push!(net.pre[c.t],c)
end

function connect!(net::SpikingLayersNet, pre::ASCIIString, post::ASCIIString, c::SpikingConnection)
    pred = (n) -> l.name == n # comparator function
    s = findfirst(l->l.name==pre,net.l)
    t = findfirst(l->l.name==post,net.l)
    if s == 0
        error("Layer '$pre' not found")
    end
    if t == 0
        error("Layer '$post' not found")
    end
    c.s = s
    c.t = t
    addSpikingConnection!(net,c)
end

function add_layer!(net::SpikingLayersNet, layer::AbstractSpikingLayer)
    nv = num_vertices(net.g)
    push!(net.l, layer)
    v = add_vertex!(net.g)
    # extend matrix
    push!(net.pre, Vector{SpikingConnection}[])
    push!(net.post, Vector{SpikingConnection}[])
    layer
end

function normalizeWeights!(net::SpikingLayersNet)
    for conn_arr in net.pre
        for conn in conn_arr
            normalizeWeights!(conn)
        end
    end
end

function resetLayers!(net::SpikingLayersNet)
    for layer in net.l
        reset!(layer)
    end
end

### SIMULATION

function runSpikingNet!(net::SpikingLayersNet, settings::RunSettings)
    results = RunResults(net,settings)
    T=settings.T
    #stim_generator=settings.stim
    stim_spikes = settings.stim_spikes
    time_trace=0:dt:T
    nsteps=length(time_trace)    

    

    if SHOW_PROGRESS
        update_interval = 2 # seconds
        progress = Progress(nsteps,update_interval) # min update interval = 2 sec
    end
    # simulate

    ts = zeros(length(net.l))
    for i=2:nsteps
        t = time_trace[i]
        ts[:] = t
        # parallelized version - update all the layers, then update all the synapses (needs layers)
        # to finish updating first
        
        # inputs to each layer at this given timestep
        stims = [(s == nothing) ? nothing : s[:,i] for s in stim_spikes]
        
        for (li, layer) in enumerate(net.l)
            # update layer
            update!(layer, net.pre[li], stims[li], t)
            # update synapses
            for sc in net.post[li]
                update!(sc,layer)
                if sc.stdp_enabled
                    updateSTDP!(sc, layer, net.l[sc.t])
                end
            end
        end
        recordSpikes!(results, net, i)
        if SHOW_PROGRESS
            next!(progress)
        end
    end
    results
end


