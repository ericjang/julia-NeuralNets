
# connectivity functions specific to this project
using Base.Test

function TopographicWeights2D{T}(width_pre, width_post, kernel::Array{T,2}=reshape([1],1,1))
	# lists to return
	pre = Int[]
	post = Int[]
	weight = T[]

	(small_w, big_w) = sort([width_post, width_pre])

	kw=size(kernel,1)
	ks=(kw-1)/2 # num units to left or right

	big_d = [big_w big_w]
	small_d = [small_w small_w]

	# mapping from many tiles to few tiles using kernel
	for br=1:big_w
		for bc=1:big_w
			# (br, bc) = center of bigger map
			(sr, sc) = int(ceil([br, bc]/big_w * small_w)) # corresponding tile on the smaller map
			small_idx = sub2ind(small_d, sr, sc)
			# now for each element covered by kernel on the bigger tiles,
			# map back to that smaller tile
			for kr = 1:kw # [kr, kc] = location in kernel coordinates
				for kc = 1:kw
					rrange=(br-kw):(br+kw)
					crange=(bc-kw):(bc+kw)
					# location in big-layer coords
					brr = int(rrange[kr])
					bcc = int(crange[kc])
					K = kernel[kr,kc]
					if (0<brr<big_w+1) && (0<bcc<big_w+1) && K!=0 # no edge spillover, kernel is defined
						big_idx = sub2ind(big_d, brr, bcc)
						push!(pre, small_idx)
						push!(post, big_idx)
						push!(weight, K)
					end
				end
			end
		end
	end

	# big is actually pre, and small is actually post
	# - flip flop the two
	if (width_pre > width_post) 
		(post, pre) = (pre, post)
	end
	return (pre, post, weight)
end

function rand_uniform(a, b)
    a + rand()*(b - a)
end

# currently unused
function all_to_all(pre_N, post_N, stype::SynapseType, stdp_enabled)
    syn = SpikingSynapse[]
    for i=1:(pre_N*post_N)
        w = 1
        delay = 4
        (s,t) = ind2sub((pre_N,post_N),i)
        s = SpikingSynapse(stype[i],s,t,float(w),float(delay))
        push!(syn,s)
    end
    SpikingConnection(syn,stdp_enabled)
end

# computes initial weights from Photoreceptor layers to LGN
function p_lgn_connectivity(pre_N, post_N, stype::SynapseType, base_weight, stdp_enabled)
	# this now acts as a pooling kernel

	(small_N, big_N) = sort([pre_N, post_N])
	kw = sqrt(big_N/small_N)
	if !isinteger(kw)
		error("kernel width ratio must be an Int64 - got $(kw) instead")
	end
	kw = int(kw)
	kernel = ones(kw, kw)
	(pre, post, w) = TopographicWeights2D(sqrt(pre_N), sqrt(post_N), kernel)
	syn = Array(SpikingSynapse,length(pre))
	for i=1:length(pre)
		delay = 1.0 # ms
		w = base_weight * rand_uniform(0.5,2)		
		@test pre[i] <= pre_N
		@test post[i] <= post_N
		syn[i] = SpikingSynapse(stype,pre[i],post[i],w,delay)
	end	
	SpikingConnection(syn,stdp_enabled)
end


# TODO - below generators need to be fixed!
# topographic weights from lgn layers to v1 (cortex) layers
# and from v1->v1
function forward_connectivity(pre_N, post_N, stype::SynapseType, base_weight, stdp_enabled)
	kernel = [
	    0 1 0
	    1 1 1
	    0 1 0
	];
	(pre, post, w) = TopographicWeights2D(sqrt(pre_N), sqrt(post_N), kernel)
	
	syn = Array(SpikingSynapse,length(pre))
	for i=1:length(pre)
		delay = 1.0
		w = base_weight * rand_uniform(0.5,2)
		@test pre[i] <= pre_N
		@test post[i] <= post_N

		syn[i] = SpikingSynapse(stype,pre[i],post[i],w,delay)
	end	
	SpikingConnection(syn,stdp_enabled)
end

# lateral connections in cortex layer
function lateral_connectivity(N, w_pot::Float64, w_dep::Float64)
	# topographic lateral connectivity kernels
	# all weights should be positive, since we don't want synapses to flip-flop between e & i via STDP 
	e = EXC # excitatory 
	i = INH # inhibitory

	type_kernel= 
	[
	    0 0 i i i 0 0
	    0 i e e e i 0
	    i e e e e e i
	    i e e 0 e e i
	    i e e e e e i
	    0 i e e e i 0
	    0 0 i i i 0 0
	]

	width = sqrt(N)
	(pre, post, stype) = TopographicWeights2D(width, width, type_kernel)

	# delays, in ms
	A = 1; B = 2; C = 3; D = 4
	delay_kernel=[
	    0 0 D D D 0 0
	    0 D C C C D 0
	    D C B A B C D
	    D C A 0 A C D
	    D C B A B C D
	    0 D C C C D 0
	    0 0 D D D 0 0
	]
	(pre, post, delay) = TopographicWeights2D(width, width, delay_kernel)

	syn = Array(SpikingSynapse,length(pre))
	for i=1:length(pre)
		w = (stype[i] == EXC) ? w_pot : w_dep
		w *= rand_uniform(0.5,2)
		syn[i] = SpikingSynapse(stype[i], pre[i], post[i], w, float(delay[i]))
	end	
	SpikingConnection(syn,false)
end

