# julia-NeuralNets

Implementation of the paper ``Color opponent receptive fields self-organize in a biophysical model of visual cortex via spike-timing dependent plasticity'', using the Julia language.

## Simulator Features
- 4x slower than efficient C++ implementation.
- Nearest-neighbor spike-time dependent plasticity
- Hodgkin-Huxley neurons
- Conductance-based synaptic transmission
- Excitatory and inhibitory synapses
- Written in Julia, an easy-to-read language

For a faster and more feature-complete version, a C++ implementation can be found at [https://github.com/ericjang/NeuralNets](https://github.com/ericjang/NeuralNets). This model may have a few bugs and off parameters here and there. The C++ version is more likely to be correct.
