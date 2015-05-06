using NeuralNets
using PyPlot
vv=[-140:1:40];
plot(vv,map(Minf,vv),vv,map(Hinf,vv),vv,map(Ninf,vv))
xlabel("V (mV)");
title("Voltage-dependent Gating Variable Steady States");
legend(["Na+ activation","Na+ inactivation","K+ activation"],loc="best")

println("Press Enter to Continue...")
readline()
