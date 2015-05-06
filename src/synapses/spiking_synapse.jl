const τ_e = 5 
const τ_i = 10
const g_spike = 1 

# at the expense of using BLAS + slicing to perform layer updates, every synapse is evaluated separately


function SpikingSynapse(stype::SynapseType, s::Int64, t::Int64, w::Float64, d::Float64)
	tau = (stype == EXC) ? τ_e : τ_i
	g = 0
	_ql = int(d/dt)+1
	incoming = falses(_ql)
	head = 1
	SpikingSynapse(stype,s,t,w,d,g,tau,incoming,head,_ql)
end

function update!(syn::SpikingSynapse, source::AbstractSpikingNeuron)
	syn.g += dt*(-syn.g/syn.tau)
	if syn.incoming[syn._head]
		syn.g += g_spike
	end
	# cycle forward
	
	# in a 0-indexed language:
	# end = (head + cl-1 ) % cl
	# therefore, in a 1-indexed language (convert to 0-index language, then back):
	# end = ((head-1) + ql - 1) % ql + 1
	e = ((syn._head-1)+syn._ql-1) % syn._ql + 1
	syn.incoming[e] = source.didSpike
	syn._head = syn._head%syn._ql+1
end

