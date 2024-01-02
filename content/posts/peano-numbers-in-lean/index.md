---
title: 'Peano numbers in Lean'
tags:
- Math
- Lean
- Programming
date: 2024-01-05
draft: true
math: true
---

<!-- https://en.wikipedia.org/wiki/Peano_axioms -->
<!-- https://wiki.haskell.org/Peano_numbers -->

In this post, I will define the natural numbers using using the [Peano axioms](https://en.wikipedia.org/wiki/Peano_axioms), which will be referred to here as Peano numbers, and demonstrate that the set of natural numbers $\N$ equipped with ordinary addition and multiplication is a [commutative semiring](https://en.wikipedia.org/wiki/Semiring#Commutative_semirings), i.e., that $(\N, +, 0)$ and $(\N, \cdot, 1)$ are both [commutative monoids](https://en.wikipedia.org/wiki/Monoid#Commutative_monoid) such that $a \cdot 0 = 0$ and $a \cdot (b + c) = a \cdot b + a \cdot c$.

<!-- TODO: talk about lean -->
The purpose of this post is to explore Lean capabilities for demonstrating some simple properties and theorems.

<!-- TODO: better section name -->
## Defining the Peano numbers

In Lean, the Peano numbers can be defined as [inductive type](https://lean-lang.org/theorem_proving_in_lean/inductive_types.html). In fact, the [natural numbers in Lean](https://lean-lang.org/lean4/doc/nat.html) are defined in this exactly way. Here, I will define them like this:

```lean
inductive Peano : Type
| _0 : Peano
| S : Peano → Peano
```

Here, `_0` represents the natural number 0 and `S` represents the successor operation, and both are constructors for the type `Peano`. I also define a the natural number 1 with `def _1 := S _0`, that will be used to show some properties of the addition and multiplication operations.

<!-- TODO: better section name -->
## Forming a commutative semiring with the natural numbers

As stated at the introduction of this post, the natural numbers equipped with ordinary addition and multiplication can be described as the commutative semiring $(\N, +, 0, \cdot, 1)$, which has the following properties:

- $(\N, +, 0)$ is the commutative monoid of $\N$ under addition, with identity element 0:
  - Addition associativity: $(a + b) + c = a + (b + c)$.
  - Addition identity element: $a + 0 = a$.
  - Addition commutativity: $a + b = b + a$.
- $(\N, \cdot, 1)$ is the commutative monoid of $\N$ under multiplication, with identity element 1:
  - Multiplication associativity: $(a \cdot b) \cdot c = a \cdot (b \cdot c)$.
  - Multiplication identity element: $a \cdot 1 = a$.
  - Multiplication commutativity: $a \cdot b = b \cdot a$.
- Multiplication by 0 annihilates $\N$: $a \cdot 0 = 0$.
- Multiplication distributes over addition: $a \cdot (b + c) = a \cdot b + a \cdot c$.

{{< alert coffee >}}
But why can't we treat $(\N, +, 0, \cdot, 1)$ as a [commutative ring](https://en.wikipedia.org/wiki/Commutative_ring) instead?
{{< /alert >}}

This is because we would have to define the additive inverse $-a$, which is impossible given that we only have non-negative numbers, and the multiplicative inverse $1/a$, also impossible given that $1/a$ is not an integer if $a \neq 1$.
