# single HH neuron
using NeuralNets

include("../apma2821v/stimuli.jl")

net = SpikingNet()
add_layer!(net,HHLayer("single",1))
T = 300
dt = 0.01

measurements = ["single"=>["v","didSpike","m","h","n"]]
settings = RunSettings(T,dt,step_stim,measurements)

out = runSpikingNet(net,settings)

# analysis
using PyPlot

time_trace = 0:dt:T
v = out.data["single"]["v"]'
didSpike = out.data["single"]["didSpike"]'
println("Number of spikes:", length(find(didSpike)))

plot(time_trace[find(didSpike)],v[find(didSpike)],"r.")
plot(time_trace,v)
ylim([-80, 0])
show()

figure()
for var in ["m","h","n"]
    plot(time_trace,out.data["single"][var]')
end
legend(["m","h","n"])
show()

println("Press Enter to Continue...")
readline()