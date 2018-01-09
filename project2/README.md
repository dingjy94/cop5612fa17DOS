# Project2
JingyiDing 69364001

## Run

```./project2 numNodes topology algorithm```

## What is working
For each topologies, there is a controller. Controller use Genserver to start gossip or push sum node processes, and tell each process its neighbours. After every nodes start, controller randomly choose a node, and sent it {:start} to let it start to communication with other nodes.

For gossip algorithm, when a node receive roumor from other nodes, it send the roumor to one of its neighbors and its variable 'count' increase 1. When this 'count' achieve 10, the node send a information to controller to annonce that it is terminated. After all of nodes have annonced terminated, the controller stop the program. In order to maker sure every nodes receive roumor, the node whose count achieve 10 don't really terminate, but keep transformting the roumor.

For push sum algorithm, the basic is same as gossip one. When a node's s/w ration achieve pow(10, -10), it sent a message to controller. Similiary, the this node doesn't really terminate, but keep transforming (s/2, w/2).

##Largest Network
For gossip algorithm:
Line 200 nodes, other 3 are 1225(35*35)

For push sum algorithm:
Lin and 2D both 700,
other 2 are 1225


