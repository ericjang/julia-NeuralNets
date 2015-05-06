using NeuralNets
using HDF5, JLD
using ProgressMeter

image_names = readdir("../images")

nTrain = 20 # 2000
N_stim = 100 # input dim
T = 300 # msec
dt = NeuralNets.dt
imgs = image_names[rand(1:length(image_names),nTrain)] # chosen images


net = buildnet()

progress = Progress(nTrain,1)
println("Starting Training Procedure with $nTrain iterations...")
for itr=1:nTrain
	img_name = string("../images/", imgs[itr])
	spike_train = image_stim(img_name, int(sqrt(N_stim)), T, dt)
	
	stim_spikes = cell(length(net.l))
	for li=1:length(net.l)
		if li in 1:3
			stim_spikes[li] = spike_train[:,:,li]
		else
			stim_spikes[li] = nothing
		end
	end
	rs = RunSettings(T,stim_spikes)
	resetLayers!(net)
	result = runSpikingNet!(net,rs)
	normalizeWeights!(net)

	if itr%5==0 || itr == 1
		fname = string("../data/t2_", itr, ".jld")
		println("Saving Data...")
		save(fname,"pre", net.pre, "runresult", result)
	end
	next!(progress)
end
