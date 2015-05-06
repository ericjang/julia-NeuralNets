using Base.Test
using NeuralNets
using PyPlot

include("../apma2821v/plotting.jl")

# very strong all-to-all connections
function strong(pre_N, post_N, stype::SynapseType, stdp_enabled)
    syn = Synapse[]
    for i=1:(pre_N*post_N)
        w = 1
        delay = 5
        (s,t) = ind2sub((pre_N,post_N),i)
        s = Synapse(stype[i],s,t,float(w),float(delay))
        push!(syn,s)
    end
    SpikingConnection(0,0,syn,stdp_enabled,20.0,10.0,5.0)
end

# only stim the E1 neuron
function E1_stim(l::Int64, N::Int64, i::Int64)
    Iinj = zeros(N)
    if l==1
        dt = 0.01
        Iinj = 30 * (int(i*dt/20)%2)* ones(N)
    end
    Iinj
end

function genplots(out::RunResults, time_trace)
    figure()
    subplot(1,2,1)
    lnames=["E1","E2"]
    ax = cell(2)
    for (i,lname) in enumerate(lnames)
        v = out.data[lname]["v"]'
        didSpike = out.data[lname]["didSpike"]'
        ax[i] = plot(time_trace,v)
        plot(time_trace[find(didSpike)],v[find(didSpike)],"r.")
    end
    legend([ax[1],ax[2]],lnames)
    ylim([-100,10])
    title("v")

    subplot(1,2,2)
    for (i,lname) in enumerate(lnames)
        g = out.data[lname]["gsyn"]'
        plot(time_trace,g)
        #ylim([-10,10])
        title("Presynaptic Conductance")
    end
    show()    
end


T = 300
dt = 0.01
time_trace = 0:dt:T
measurements = [E=>["v","didSpike","gsyn"] for E in ["E1","E2"]]
settings = RunSettings(T,dt,E1_stim,measurements)
plot_stim(settings,["E1","E2"])


# no STDP
net = SpikingNet()
add_layer!(net,HHLayer("E1",1))
add_layer!(net,HHLayer("E2",1))
connect!(net, "E1", "E2", strong, EXC, false)
out = runSpikingNet(net,settings)
genplots(out,time_trace)

@test out.data["E1"]["v"] != out.data["E2"]["v"]

# now, enable STDP
# Now we enable STDP in the single synapse from E1->E2. STDP is triggered 
# on a synapse when either it's source or target neuron fires. When green (above) spikes, 
# the duration Δt = green - blue is short, so LTP is strong. When blue spikes, 
# Δt = green - blue < 0, but since the duration is long, the LTP effect is weak.
# There is no reciprocal connection from E2->E1, so potentiation only occurs on one synapse.

net2 = SpikingNet()
add_layer!(net2,HHLayer("E1",1))
add_layer!(net2,HHLayer("E2",1))
connect!(net2, "E1", "E2", strong, EXC, true)

println("starting weight: ", net2.pre[2][1].synapses[1].w)
out = runSpikingNet(net2,settings)
println("ending weight: ", net2.pre[2][1].synapses[1].w)

genplots(out,time_trace)

println("Press Enter to Continue...")
readline()


