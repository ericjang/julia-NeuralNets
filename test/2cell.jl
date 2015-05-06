# verifies that identical stimulus presented to 2 disconnected cells produces exactly the same datas

using Base.Test
using NeuralNets
function all_to_all(pre_N, post_N, stype::SynapseType, stdp_enabled)
    syn = Synapse[]
    for i=1:(pre_N*post_N)
        w = 1
        delay = 4
        (s,t) = ind2sub((pre_N,post_N),i)
        s = Synapse(stype[i],s,t,float(w),float(delay))
        push!(syn,s)
    end
    SpikingConnection(syn,stdp_enabled)
end

T = 300
dt = 0.01
time_trace = 0:dt:T
net = SpikingNet()
add_layer!(net,HHLayer("E1",1))
add_layer!(net,HHLayer("E2",1))
#connect!(net, "E1", "E2", all_to_all, EXC, false)
function stim(l::Int64, N::Int64, i::Int64)
    Iinj = zeros(N)
    if 25/dt<i<100/dt
        Iinj = ones(N)*30    
    end
    Iinj
end

measurements = [E=>["v","didSpike"] for E in ["E1","E2"]]
settings = RunSettings(T,dt,stim,measurements)
out = runSpikingNet(net,settings)
@test out.data["E1"]["v"] == out.data["E2"]["v"]