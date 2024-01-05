---
title: 'Peano numbers in Lean'
tags:
- Math
- Lean
- Programming
date: 2024-01-10
draft: true
math: true
---

<!-- https://en.wikipedia.org/wiki/Peano_axioms -->
<!-- https://wiki.haskell.org/Peano_numbers -->

In this post, I will define the natural numbers using using the [Peano axioms](https://en.wikipedia.org/wiki/Peano_axioms), which will be referred to here as Peano numbers, and proof that the set of natural numbers $\N$ equipped with ordinary addition and multiplication is a [commutative semiring](https://en.wikipedia.org/wiki/Semiring#Commutative_semirings), i.e., that $(\N, +, 0)$ and $(\N, \cdot, 1)$ are both [commutative monoids](https://en.wikipedia.org/wiki/Monoid#Commutative_monoid) such that $a \cdot 0 = 0$ and $a \cdot (b + c) = a \cdot b + a \cdot c$.

The purpose of this post is to explore Lean's capabilities in helping prove some simple theorems related to algebra.

## Defining the Peano numbers

In Lean, the Peano numbers can be defined as an [inductive type](https://lean-lang.org/theorem_proving_in_lean/inductive_types.html). In fact, the [natural numbers in Lean](https://lean-lang.org/lean4/doc/nat.html) are defined exactly like this. Likewise, I will define them like this:

```lean
inductive Peano : Type
| _0 : Peano
| S : Peano → Peano
```

Here, `_0` represents the natural number 0 and `S` represents the successor operation, and both are constructors for the type `Peano`. I will also define the natural number 1 with `def _1 := S _0`, which will be used to show some properties of the addition and multiplication operations.

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
- Multiplication absorbing element $\N$: $a \cdot 0 = 0$.
- Multiplication distributes over addition: $a \cdot (b + c) = a \cdot b + a \cdot c$.

{{< alert coffee >}}
But why can't we treat $(\N, +, 0, \cdot, 1)$ as a [commutative ring](https://en.wikipedia.org/wiki/Commutative_ring) instead?
{{< /alert >}}

This is because we would have to define the additive inverse $-a$ s.t. $a - a = 0$ and also define the multiplicative inverse $a^{-1}$ s.t. $aa^{-1} = 1$, both impossible given that we are working with the set of natural numbers.

## Proving the properties in Lean

Now, we can start to proof all the described properties in Lean. I will not make the use of any library, like [mathlib4](https://github.com/leanprover-community/mathlib4), so everything will be done in vanilla Lean 4.

### Addition-related properties

In this section, I will show the proofs for associativity, the identity element and commutativity, mostly inspired by the [Wikipedia article with proofs involving addition](https://en.wikipedia.org/wiki/Proofs_involving_the_addition_of_natural_numbers). To start the proof, I will register the `Add` instance for the `Peano` type, allowing us to use the binary operator `+` for addition:

```lean
instance : Add Peano where
  add a b := _add a b where
    _add a b := match b with
      | _0 => a
      | S b' => S (_add a b')
```

#### Associativity

The associative property $(a + b) + c = a + (b + c)$ can be proofd by induction on the number $c$:

```lean
@[simp]
theorem add_associativity (a b c : Peano)
  : (a + b) + c = a + (b + c) := by
    induction c with
    | _0 => rfl
    | S c' ih => calc
      a + b + S c' = S (a + b + c')   := by rfl
      _            = S (a + (b + c')) := by rw [ih]
      _            = a + (b + S c')   := by rfl
```

Here, `rfl` stands for reflexivity, a Lean tactic that tries to close the current goal using the reflexive property, and `ih` is the inductive hypothesis, defined as $a + b + c\' = a + (b + c\')$, where $c\'$ is a natural number s.t. its successor is equal to $c$. I also defined this theorem with `@[simp]`, which states that this theorem can be used by the [`simp`](https://leanprover-community.github.io/extras/simp.html) tactic to simplify the main goal.

#### Identity element

The identity element for addition is 0, so we have to proof that $a + 0 = a$. I will also proof that $0 + a = a$, which will be useful when showing the proof for the addition commutativity.

For the right identity, we can simply use the `rfl` tactic, because Lean will match $a + 0$ with the addition definition:

```lean
@[simp]
theorem right_add_identity (a : Peano) : a + _0 = a := by
  rfl
```

For the left identity, the proof can be easily done by induction on $a$:

```lean
@[simp]
theorem left_add_identity (a : Peano) : _0 + a = a := by
  induction a with
  | _0 => rfl
  | S a' ih => calc
    _0 + S a' = S (_0 + a') := by rfl
    _ = S a' := by rw [ih]
```

#### Commutativity

The commutative property for addition can be divided into two steps:
1. proof the property for a natural number $a$ and $1$ ($a + 1 = 1 + a$).
2. From the last property, proof the same but for all pairs of natural numbers ($a + b = b + a$).

The first step can be done with induction on the number $a$, very similar to the `left_add_identity` proof:

```lean
@[simp]
theorem add_commutativity_1 (a : Peano) : a + _1 = _1 + a := by
  induction a with
  | _0 => rfl
  | S a' ih => calc
    S a' + _1 = S (a' + _1) := by rfl
    _ = S (_1 + a') := by rw [ih]
    _ = _1 + S a' := by rfl
```

Finally, we can show the addition commutativity with the `simp` tactic, that will apply all the theorems defined previously when possible.

```lean
@[simp]
theorem add_commutativity (a b : Peano) : a + b = b + a := by
  induction b with
  | _0 => simp
  | S b' ihb => calc
    a + S b' = a + b' + _1 := by rfl
    _ = b' + _1 + a := by simp [ihb]
    _ = S b' + a := by rfl
```

Here, the first `simp` is applying both `right_add_identity` and `left_add_identity` to reduce the base statement $a + 0 = 0 + a$ to $a = a$. Moreover, the second `simp`, written as `simp [ihb]`, tells Lean that the inductive hypothesis defined in `ih` should also be considere in the simplification process.

### Multiplication-related properties

Now, I will do an analogous process from the last section. First, I will also register the `Mul` instance, allowing us to use the binary operator `*` for multiplication:

```lean
instance : Mul Peano where
  mul a b := _mul a b where
    _mul a b := match b with
      | _0 => _0
      | S b' => a + _mul a b'
```

#### Identity ans annihilating elements

Similar to the addition identity element proofs, I will show the identity ($a * 1 = 1$) ans annihilating ($a \cdot 0 = 0$) element property for both sides:

```lean
@[simp]
theorem right_mul_identity (a : Peano) : a * _1 = a := by
  rfl

@[simp]
theorem left_mul_identity (a : Peano) : _1 * a = a := by
  induction a with
  | _0 => rfl
  | S a' ih => calc
    _1 * S a' = _1 + _1 * a' := by rfl
    _ = a' + _1 := by rw [ih, add_commutativity]
    _ = S a' := by rfl
```

```lean
@[simp]
theorem right_mul_annihilating (a : Peano) : a * _0 = _0 := by
  rfl

@[simp]
theorem left_mul_annihilating (a : Peano) : _0 * a = _0 := by
  induction a with
  | _0 => rfl
  | S a' ih => calc
    _0 * S a' = _0 + _0 * a' := by rfl
    _ = _0 + _0 := by rw [ih]
    _ = _0 := by rfl
```

#### Distributivity

The distributive property was a bit tricky for me, because it would be much easier to prove it with the associative property for multiplication. However, I couldn't find a way elaborate a proof for associativity without depending on the on the distributive property.

So, I had to split this proof into 4 steps:
1. Prove a intermediate left-distributive property $a \cdot (b + 1) = a + a \cdot b$.
2. Prove the right-distributive property $(b + c) \cdot a = b \cdot a + c \cdot a$.
3. Prove a intermediate right-distributive property $(a + 1) \cdot b = a \cdot b + b$.
4. Prove the left-distributive property $a \cdot (b + c) = a \cdot b + a \cdot c$.

For steps 1 and 2, the proof were not so much harder than the previous ones:

```lean
@[simp]
theorem left_mul_distributivity' (a b : Peano)
  : a * S b = a + a * b := by
    induction a with
    | _0 => simp only [left_mul_annihilating]; rfl
    | S a' => rfl

@[simp]
theorem right_mul_distributivity (a b c : Peano)
  : (b + c) * a = b * a + c * a := by
    induction a with
    | _0 => simp
    | S a' ih => calc
      (b + c) * S a' = (b + c) + (b + c) * a' := by rfl
      _ = b + (b * a' + c + c * a') := by simp [ih]
      _ = b + (b * a' + (c + c * a')) := by rw [add_associativity]
      _ = b * S a' + c * S a' := by simp
```
