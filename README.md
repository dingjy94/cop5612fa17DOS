# cop5612fa17DOS
Course projects of COP5612, distribute operating system. There are 4 projects, and the final project has two parts.

## 1. Bitcoin
#### Input: 
The input provided (as command line to your ./project1) will be k, the required number of 0’s of the bitcoin.
#### Output: 
Print, on independent lines, the input string and the corresponding SHA256 hash separated by a TAB, for each of the bitcoins you find. Obviously, your SHA256 hash must have the required number of leading 0s (k = 3 means 3 0’s in the hash notation). An extra requirement, to ensure every group finds different coins, it to have the input string prefixed by the gatorlink ID of one of the team members.

#### Distributed implementation: 
The more cores you have to more coins you can mine. To this end, enlisting other machines adds to your coin mining capabilities. Extend project1 so that the argument is a computer address or IP address of the server. This program then becomes a “worker” and contacts the server to get work. This second program will not display anything. All the cons found have to be displayed by the server.

````project1 10.22.13.155````
will start a worker that contact the elixir server hosted at 10.22.13.155 and participates into mining. Hint. when testing this, have your project partner start a server, find the IP address of the server and then start the worker.
Notice, your server should be able to mine coins without any workers but has to accommodate workers as they become available.

## 2. Gossip Simulator
#### Gossip Algorithm for information propagation
- **Starting:** A participant(actor) it told/sent a roumor(fact) by the main process
- **Step:** Each actor selects a random neighboor and tells it the roumor
- **Termination:** Each actor keeps track of rumors and how many times it has heard the rumor. It stops transmitting once it has heard the roumor 10 times (10 is arbitrary, you can select other values).

#### Push-Sum algorithm for sum computation
- **State:** Each actor Ai maintains two quantities: s and w. Initially, s = xi = i (that is actor number i has value i, play with other distribution if you so desire) and w = 1
- **Starting:** Ask one of the actors to start from the main process.
- **Receive:** Messages sent and received are pairs of the form (s, w). Upon receive, an actor should add received pair to its own corresponding val- ues. Upon receive, each actor selects a random neighboor and sends it a message.
- **Send:** When sending a message to another actor, half of s and w is kept by the sending actor and half is placed in the message.
- **Sum estimate:** At any given moment of time, the sum estimate is s/w where s and w are the current values of an actor.
- **Termination:** If an actors ratio s did not change more than 10^−10 in w/3 consecutive rounds the actor terminates. 

#### Topologies
- **Full Network**
- **2D Grid:** Actors form a 2D grid. The actors can only talk to the grid neigboors.
- **Line**
- **Imperfect 2D Grid:** Grid arrangement but one random other neighboor is selected from the list of all actors (4+1 neighboors).

#### Input
```project2 numNodes topology algorithm```