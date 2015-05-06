using PyPlot

function plot_stim(settings::RunSettings, layerNames::Vector{ASCIIString})
	dt = settings.dt
	T = settings.T
	time_trace = 0:dt:T
	nsteps = length(time_trace)
	fstim = settings.stim

	figure()
	for (l,lname) in enumerate(layerNames)
	    # show injections
	    stim_trace = [fstim(l,1,i) for i in 1:nsteps]
	    plot(time_trace,stim_trace)
	end
	legend(layerNames) 
	ylim([-10, 80])
	show()
end

# raster is a units going down rows, true/false going across columns (time)
function plot_raster(spikes,N,nsteps)
	C = [t for (t,i) in spikes]
	R = [i for (t,i) in spikes]
	vlines(C,R-0.5,R+0.5) # vlines(x,ymin,ymax)
	xlim([0, nsteps])
	ylim([0, N])
end

# generic network plotting, from first layer to last
function plot_all_rasters(results::RunResults)
	T = results.T
	dt = results.dt
	nsteps = length(0:dt:T)
	nL = length(results.names)
	i=0
	for (i,layer_name) in results.names
		subplot(1,nL,i)
		N = results.N[i]
		spikes = results.spikes[i]
		plot_raster(spikes,N,nsteps)
		title(layer_name)
		i+=1
	end
end

# for plotting the vision architecture
function plot_vision_rasters(results::RunResults)
	T = results.T
	dt = results.dt
	nsteps = length(0:dt:T)	
	D = (3,13)

	nL = length(results.names)
	for i=1:nL
		layer_name = results.names[i]
		println((i,layer_name))
		N = results.N[i]
		spikes = results.spikes[i]
		if i in 1:3
			subplot2grid(D,(i-1,0),colspan=2)
		elseif i in 4:6
			subplot2grid(D,(i%4,2),colspan=2)
		elseif i in 7:9
			subplot2grid(D,(0,(i-6)*3+1),rowspan=3, colspan=3) # V1_4
		else
			error("plot_vision_rasters only works with the 9-layer network")
		end
		plot_raster(spikes,N,nsteps)
		#xticks(0:dt:T) # in ms
		title(layer_name)
	end
end