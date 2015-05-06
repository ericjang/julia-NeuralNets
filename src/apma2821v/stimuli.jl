# some simple stimuli functions

using Images
using Color

# function step_stim(l::Int64, N::Int64, i::Int64)
#     Iinj = zeros(N)
#     dt = 0.01
#     if 25/dt<i<100/dt
#         Iinj = ones(N)*30    
#     end
#     Iinj
# end

function image_stim(filename,width_stim::Integer,T,dt)
	time_trace = 0:dt:T
	nsteps = length(time_trace)
	N_stim = width_stim^2
	img = Images.imread(filename);
	#img_lms = convert(Image{LMS},float32(img))
	x0 = ceil((size(img,1)-width_stim)*rand())
	y0 = ceil((size(img,2)-width_stim)*rand())
	#patch_lms = img_lms[x0:x0+width_stim-1, y0:y0+width_stim-1];
	patch_rgb = img[x0:x0+width_stim-1, y0:y0+width_stim-1]
	spike_train = falses(N_stim,nsteps,3)

	for i=1:N_stim	
		R = patch_rgb[i].r
		G = patch_rgb[i].g
		B = patch_rgb[i].b

		# L channel
	#	input_freq = 40 * patch_lms[i].l + 0.01# [Hz]
		input_freq = 40 * (R+G*.7+B*.25)/(1+.7+.25) + 0.01
		ISI = int(round(1/input_freq * 1000/dt))# in steps 
		spike_train[i,1:ISI:end,1] = true

		# M channel
	#	input_freq = 40 * patch_lms[i].m + 0.01# [Hz]
		input_freq = 40 * (G+R*.7+B*.25)/(1+.7+.25) + 0.01
		ISI = int(round(1/input_freq * 1000/dt))# in steps 
		spike_train[i,1:ISI:end,2] = true

		# S channel
	#	input_freq = 40 * patch_lms[i].s + 0.01# [Hz]
		input_freq = 40 * B + 0.01
		ISI = int(round(1/input_freq * 1000/dt))# in steps 
		spike_train[i,1:ISI:end,3] = true
	end
	spike_train
end
