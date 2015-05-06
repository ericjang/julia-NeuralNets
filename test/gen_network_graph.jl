using NeuralNets
net = buildnet()
using Graphs
to_dot(net.g,"net.dot")
run(`dot -Tpng net.dot -o net_diagram.png`)
println("Network graph written to net_diagram.png")