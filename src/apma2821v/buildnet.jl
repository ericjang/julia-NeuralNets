
function buildnet()
	net = SpikingLayersNet()

	# create layers
	P_L = add_layer!(net, SpikingLayer(SimpleSpikingNeuron,"P_L",100))
	P_M = add_layer!(net, SpikingLayer(SimpleSpikingNeuron,"P_M",100))
	P_S = add_layer!(net, SpikingLayer(SimpleSpikingNeuron,"P_S",100))

	LGN_L = add_layer!(net, SpikingLayer(HHNeuron,"LGN_L",900))
	LGN_C1 = add_layer!(net, SpikingLayer(HHNeuron,"LGN_C1",900))
	LGN_C2 = add_layer!(net, SpikingLayer(HHNeuron,"LGN_C2",900))

	V1_4 = add_layer!(net, SpikingLayer(HHNeuron,"V1_4",900))
	V1_23 = add_layer!(net, SpikingLayer(HHNeuron,"V1_23",900))
	V1_5 = add_layer!(net, SpikingLayer(HHNeuron,"V1_5",900))

	# wire it up!
	# L Photoreceptor -> LGN
	w = 0.005
	#w = 3. # ridiculous weights - just to make sure it will spike

	# L Photoreceptor -> LGN
	for target in ["LGN_L", "LGN_C1", "LGN_C2"]
		c = p_lgn_connectivity(P_L.N, LGN_L.N, EXC, w, false)
		connect!(net, "P_L", target, c)
		println(length(c.synapses))
	end

	# M Photoreceptor -> LGN
	for target in ["LGN_L", "LGN_C2"]
		c = p_lgn_connectivity(P_M.N, LGN_L.N, EXC, w, false) # be careful about this kind of code. assumes LGN are same size!
		connect!(net, "P_M", target, c)
		println(length(c.synapses))
	end

	# M->LGN is inhibitory
	c = p_lgn_connectivity(P_M.N, LGN_C1.N, INH, w, false)
	connect!(net, "P_M", "LGN_C1", c)
	println(length(c.synapses))

	# S Photoreceptor -> LGN
	c = p_lgn_connectivity(P_S.N, LGN_C1.N, INH, w, false)
	connect!(net, "P_S", "LGN_C1", c)
	println(length(c.synapses))

	# LGN->V1 cortex
	c = forward_connectivity(LGN_L.N, V1_4.N, EXC, w, true)
	connect!(net, "LGN_L",  "V1_4", c)
	println(length(c.synapses))

	c = forward_connectivity(LGN_C1.N, V1_4.N, EXC, w, true)
	connect!(net, "LGN_C1", "V1_4", c)
	println(length(c.synapses))
	
	c = forward_connectivity(LGN_C2.N, V1_23.N, EXC, w*1.5, true)
	connect!(net, "LGN_C2", "V1_23", c)
	println(length(c.synapses))

	# V1->V1
	c = forward_connectivity(V1_4.N, V1_23.N, EXC, w*1.5, true)	
	connect!(net, "V1_4", "V1_23", c)
	println(length(c.synapses))

	c = forward_connectivity(V1_23.N, V1_5.N, EXC, w*3, true)	
	connect!(net, "V1_23", "V1_5", c)
	println(length(c.synapses))

	# lateral connectivities
	w_pot = w * 0.9; w_dep = w * 1.5 * 1.7;
	c = lateral_connectivity(V1_4.N, w_pot, w_dep)
	connect!(net, "V1_4", "V1_4", c)
	println(length(c.synapses))

	w_pot = w * 0.9; w_dep = w * 1.5 * 1.7; # weights are wrong
	c = lateral_connectivity(V1_4.N, w_pot, w_dep) # replace with V1_23!
	connect!(net, "V1_23", "V1_23", c)
	println(length(c.synapses))
	
	w_pot = w * 0.9; w_dep = w * 1.5 * 1.7;
	c = lateral_connectivity(V1_4.N, w_pot, w_dep)
	connect!(net, "V1_5", "V1_5", c)
	println(length(c.synapses))

	net
end

