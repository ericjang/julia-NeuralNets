# Hodkin-Huxley spiking layer & net


### HH FUNCTIONS

# helper function: traps for 0 in denominator of rate eqns.
vtrap = (x,y) -> (abs(x/y)<1e-6) ? y*(1 - x/y/2) : x/(exp(x/y) - 1); 
# Na channel activation
αM = v-> .1 * vtrap(-(v+40),10)
βM = v-> 4exp(-(v+65)/18)
# Na channel inactivation
αH = v-> .07exp(-(v+65)/20)
βH = v-> 1/(exp(-(v+35)/10)+1)
# K channel activation
αN = v-> .01vtrap(-(v+55),10)
βN = v-> 0.125*exp(-(v+65)/80);
inf = (α,β) -> α/(α+β) # for computing minf, hinf, ninf
Minf = v-> inf(αM(v),βM(v))
Hinf = v-> inf(αH(v),βH(v)) 
Ninf = v-> inf(αN(v),βN(v)) 

# Layer parameters
const Cm = 10 # Capacitative density [μF/cm^2]
const gNa = 120 # maximum Na channel conductance
const gK = 36
const gL = 1
const ENa = 115
const EK = -12
const ELeak = 0
const v_r = -65


const e_rev = 0 # reversal potential for AMPA synapses (mV)
const i_rev = -80 # reversal potential for GABA synapses (mV)
const abs_refr=5 # ms
const v_th=-20


function HHNeuron()
    HHNeuron(Minf(v_r), Hinf(v_r), Ninf(v_r), v_r, -Inf, false)
end

function update!(neuron::HHNeuron, Ge_syn::Float64, Gi_syn::Float64, Iinj::Float64, t::Float64)
	m = neuron.m
	h = neuron.h
	n = neuron.n
	v = neuron.v
	Isyn = Ge_syn.*(e_rev-v)-Gi_syn.*(i_rev-v) # total synaptic current
	vdot =  (gNa*m^3*h*(ENa-(v+65)) + gK*n^4*(EK-(v+65)) + gL*(ELeak-(v+65)) + Isyn + Iinj)/Cm

    neuron.v += dt*vdot
    neuron.m += dt*(αM(v)*(1-m) - βM(v)*m);
    neuron.h += dt*(αH(v)*(1-h) - βH(v)*h);
    neuron.n += dt*(αN(v)*(1-n) - βN(v)*n);

    neuron.didSpike = (v > v_th) & (t > neuron.lastSpike+abs_refr)
    if neuron.didSpike
    	neuron.lastSpike = t
    end
end

function reset!(neuron::HHNeuron)
    neuron.m = Minf(v_r)
    neuron.h = Hinf(v_r)
    neuron.n = Ninf(v_r)
    neuron.v = v_r
    neuron.lastSpike = -Inf
    neuron.didSpike = false
end