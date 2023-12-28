---
title: 'A Brief Introduction to Hypercube Graphs'
tags:
  - Graph Theory
date: 2024-01-01
draft: true
math: true
---

An hypercube graph $Q_d$ is a [$d$-regular](https://en.wikipedia.org/wiki/Regular_graph) [symmetric](https://en.wikipedia.org/wiki/Symmetric_graph) graph constructed over a $d$-dimensional hypercube (or $d$-cube). Here, I will present some nice properties about them and open problems still not solved!

## Definition(s)

Hypercube graphs can be defined in two (equivalent) ways. The first definition uses the [Cartesian product of graphs](https://en.wikipedia.org/wiki/Cartesian_product_of_graphs) operation ($\times$):

{{< alert pencil >}}
**Def. 1 of hypercube graphs**: the $d$-cube graph $Q_d$ can be defined recursively as
$$
\begin{align*}
Q_1 & = K_2, \\\\
Q_d & = K_2 \times Q_{d - 1}.
\end{align*}
$$
{{< /alert >}}

In this definition, $K_2$ is the complete graph with 2 nodes. In Python, using [NetworkX](https://networkx.org/), we can use it like this:

```python
import networkx as nx

def hypercube_graph(d):
    K2 = nx.complete_graph(2)
    G = K2

    for i in range(2, d + 1):
        G = nx.cartesian_product(G, K2)

    return G
```

The second definition treat each node $v$ in as a sequence of 0s and 1s of length $d$:

{{< alert pencil >}}
**Def. 2 of hypercube graphs**: let $Q_d$ be a graph. $Q_d$ is called the $d$-cube graph if $V(Q_d)$ is all the sequences $( p_i )_{i = 1}^d$, $p_i \in \\{ 0, 1 \\}$, and $\\{ u, v \\} \in E(Q_d)$ iff $u$ and $v$ differ by exactly one position on their sequences.
{{< /alert >}}

We can also write a Python script to generate graphs with this definition:

```python
import networkx as nx
import itertools

def hypercube_graph(d):
    nodes = list(itertools.product([0, 1], repeat=d))
    edges = []

    for u in nodes:
        for i in range(d):
            v = tuple([*u[:i], int(not u[i]), *u[i + 1:]])
            edges.append((u, v))

    G = nx.Graph()
    G.add_nodes_from(nodes)
    G.add_edges_from(edges)

    return G
```

## Properties

## Open Problems

## TODO

- [ ] Definitions
- [ ] Example with NetworkX
- [ ] Properties
- [ ] Open Problems

```python
import networkx as nx
import itertools
import time


def hypercube_graph_1(d):
    K2 = nx.complete_graph(2)
    G = K2

    for i in range(2, d + 1):
        G = nx.cartesian_product(G, K2)

    return G


def hypercube_graph_2(d):
    nodes = list(itertools.product([0, 1], repeat=d))
    edges = []

    for u in nodes:
        for i in range(d):
            v = tuple([*u[:i], int(not u[i]), *u[i + 1:]])
            edges.append((u, v))

    G = nx.Graph()
    G.add_nodes_from(nodes)
    G.add_edges_from(edges)

    return G


for d in range(10, 20):
    t1_start = time.process_time()
    Q_1 = hypercube_graph_1(d)
    t1_stop = time.process_time()

    t2_start = time.process_time()
    Q_2 = hypercube_graph_2(d)
    t2_stop = time.process_time()

    print(f"{d = }")
    # print("\tisomorphic:", nx.is_isomorphic(Q_1, Q_2))
    print(f"\tdef. 1 time: {t1_stop - t1_start:.5f}")
    print(f"\tdef. 2 time: {t2_stop - t2_start:.5f}")


```
