---
title: 'Peano numbers in Lean'
tags:
- Math
- Lean
- Programming
date: 2024-01-10
summary: In this post, I will define the natural numbers using the Peano axioms and prove that the set of natural numbers $\N$ equipped with ordinary addition and multiplication is a commutative semiring.
math: true
---

In this post, I will define the natural numbers using the [Peano axioms](https://en.wikipedia.org/wiki/Peano_axioms), which will be referred to here as Peano numbers, and prove that the set of natural numbers $\N$ equipped with ordinary addition and multiplication is a [commutative semiring](https://en.wikipedia.org/wiki/Semiring#Commutative_semirings), i.e., that $(\N, +, 0)$ and $(\N, \cdot, 1)$ are both [commutative monoids](https://en.wikipedia.org/wiki/Monoid#Commutative_monoid) such that $a \cdot 0 = 0$ and $a \cdot (b + c) = a \cdot b + a \cdot c$.

The purpose of this post is to explore Lean's capabilities in helping prove some simple theorems related to algebra.

## Defining the Peano numbers

In Lean, the Peano numbers can be defined as an [inductive type](https://lean-lang.org/theorem_proving_in_lean/inductive_types.html). In fact, the [natural numbers in Lean](https://lean-lang.org/lean4/doc/nat.html) are defined exactly like this. Likewise, I will define them like this:

```lean
inductive Peano : Type
| _0 : Peano
| S  : Peano → Peano
```

Here, `_0` represents the natural number 0 and `S` represents the successor operation, and both are constructors for the type `Peano`. I will also define the natural number 1 with `def _1 := S _0`, which will be used to show some properties of the addition and multiplication operations.

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

Now, we can start to prove all the described properties in Lean. I will not make the use of any library, like [mathlib4](https://github.com/leanprover-community/mathlib4), so everything will be done in vanilla Lean 4.

### Addition-related properties

In this section, I will show the proofs for associativity, the identity element and commutativity, mostly inspired by the [Wikipedia article with proofs involving addition](https://en.wikipedia.org/wiki/Proofs_involving_the_addition_of_natural_numbers). To start the proof, I will register the `Add` instance for the `Peano` type, allowing us to use the binary operator `+` for addition:

```lean
instance : Add Peano where
  add a b := _add a b
    where _add a b := match b with
      | _0   => a
      | S b' => S (_add a b')
```

#### Associativity

The associative property $(a + b) + c = a + (b + c)$ can be proven by induction on the number $c$:

```lean
@[simp]
theorem add_associativity (a b c : Peano) : (a + b) + c = a + (b + c) := by
    induction c with
    | _0 => rfl
    | S c' ih => calc
      a + b + S c' = S (a + b + c')   := by rfl
      _            = S (a + (b + c')) := by rw [ih]
      _            = a + (b + S c')   := by rfl
```

Here, `rfl` stands for reflexivity, a Lean tactic that tries to close the current goal using the reflexive property, and `ih` is the inductive hypothesis, defined as $a + b + c\' = a + (b + c\')$, where $c\'$ is a natural number s.t. its successor is equal to $c$. I also defined this theorem with `@[simp]`, which states that this theorem can be used by the [`simp`](https://leanprover-community.github.io/extras/simp.html) tactic to simplify the main goal.

#### Identity element

The identity element for addition is 0, so we have to prove that $a + 0 = a$. I will also prove that $0 + a = a$, which will be useful when showing the proof for the addition commutativity.

For the right-identity, we can simply use the `rfl` tactic, because Lean will match $a + 0$ with the addition definition:

```lean
@[simp]
theorem right_add_identity (a : Peano) : a + _0 = a := by
  rfl
```

For the left-identity, the proof can be easily done by induction on $a$:

```lean
@[simp]
theorem left_add_identity (a : Peano) : _0 + a = a := by
  induction a with
  | _0 => rfl
  | S a' ih => calc
    _0 + S a' = S (_0 + a') := by rfl
    _         = S a'        := by rw [ih]
```

#### Commutativity

The commutative property of addition can be divided into two steps:
1. prove the property for a natural number $a$ and $1$ ($a + 1 = 1 + a$).
2. From the last property, prove the same but for all pairs of natural numbers ($a + b = b + a$).

The first step can be done with induction on the number $a$, very similar to the `left_add_identity` proof:

```lean
@[simp]
theorem add_commutativity_1 (a : Peano) : a + _1 = _1 + a := by
  induction a with
  | _0 => rfl
  | S a' ih => calc
    S a' + _1 = S (a' + _1) := by rfl
    _         = S (_1 + a') := by rw [ih]
    _         = _1 + S a'   := by rfl
```

Finally, we can show the addition commutativity with the `simp` tactic, that will apply all the theorems defined previously when possible.

```lean
@[simp]
theorem add_commutativity (a b : Peano) : a + b = b + a := by
  induction b with
  | _0 => simp
  | S b' ih => calc
    a + S b' = a + b' + _1 := by rfl
    _        = b' + _1 + a := by simp [ih]
    _        = S b' + a    := by rfl
```

Here, the first `simp` is applying both `right_add_identity` and `left_add_identity` to reduce the base statement $a + 0 = 0 + a$ to $a = a$. Moreover, the second `simp`, written as `simp [ihb]`, tells Lean that the inductive hypothesis defined in `ih` should also be considere in the simplification process.

### Multiplication-related properties

Now, I will do an analogous process from the last section. First, I will also register the `Mul` instance, allowing us to use the binary operator `*` for multiplication:

```lean
instance : Mul Peano where
  mul a b := _mul a b
    where _mul a b := match b with
      | _0   => _0
      | S b' => a + _mul a b'
```

#### Identity and annihilating elements

Similar to the addition identity element proofs, I will show the identity ($a \cdot 1 = 1$) and annihilating ($a \cdot 0 = 0$) element property for both sides:

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
    _         = a' + _1      := by rw [ih, add_commutativity]
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
    _         = _0           := by rw [ih]; rfl
```

#### Distributivity

The distributive property was a bit tricky for me, because it would be much easier to prove it with the associative property of multiplication, and I couldn't find a way elaborate a proof for associativity without depending on the on the distributive property.

However, I think I landed on a satisfactory proof. For the right-distributivity, where we want to show that $(b + c) \cdot a = b \cdot a + c \cdot a$, I used the main properties defined for addition, with emphasis to the addition associativity, which I used with the `repeat` property, that applies a tactic until until it fails:

```lean
@[simp]
theorem right_mul_distributivity (a b c : Peano) : (b + c) * a = b * a + c * a := by
    induction a with
    | _0 => simp
    | S a' ih => calc
      (b + c) * S a' = (b + c) + (b + c) * a'      := by rfl
      _              = b + (b * a' + c + c * a')   := by simp [ih]
      _              = (b + b * a') + (c + c * a') := by repeat (rw [add_associativity])
      _              = b * S a' + c * S a'         := by rfl
```

For the left-distributivity, where we want to show that $a \cdot (b + c) = a \cdot b + a \cdot c$, I had a hard time with the `simp` tactic, because it started to run very slowly when I used it without any arguments. Because of this, I had to pass the `only` option, that limits `simp` to just use the expressions inside the brackets:

```lean
@[simp]
theorem left_mul_distributivity (a b c : Peano) : a * (b + c) = a * b + a * c := by
  induction a with
  | _0 => simp
  | S a' ih => calc
    S a' * (b + c)  = (a' + _1) * (b + c)           := by rfl
    _               = a' * (b + c) + _1 * (b + c)   := by rw [right_mul_distributivity]
    _               = a' * (b + c) + b + c          := by rw [left_mul_identity, add_associativity]
    _               = b + a' * b + c + a' * c       := by simp [ih]
    _               = (_1 + a') * b + (_1 + a') * c := by simp only [left_mul_identity, right_mul_distributivity, add_associativity]
    _               = S a' * b + S a' * c           := by simp only [add_commutativity]; rfl
```

#### Associativity

Basically, the associative property of multiplication, $(a \cdot b) \cdot c = a \cdot (b \cdot c)$, can be proved by induction on $c$, where we have to use the left-distributivity of multiplication, proved in the last subsection:

```lean
@[simp]
theorem mul_associativity (a b c : Peano) : (a * b) * c = a * (b * c) := by
  induction c with
  | _0 => rfl
  | S c' ih => calc
    a * b * S c' = a * b + a * b * c' := by rfl
    _            = a * (b + b * c')   := by rw [ih, left_mul_distributivity]
    _            = a * (b * S c')     := by rfl
```

#### Commutativity

Finally, we can prove the last property related to multiplication, the commutativity. Because we have all the previous properties already defined, prove this property is very simple:

```lean
@[simp]
theorem mul_commutativity (a b: Peano) : a * b = b * a := by
  induction b with
  | _0 => rw [left_mul_annihilating, right_mul_annihilating]
  | S b' ih => calc
    a * S b' = a * (b' + _1)   := by rfl
    _        = a * b' + a * _1 := by rw [left_mul_distributivity]
    _        = _1 * a + b' * a := by simp [ih]
    _        = (b' + _1) * a   := by rw [right_mul_distributivity, add_commutativity]

```

## Conclusion

For some months until now, I had the wish to learn a proof assistant language, and I have considered some languages like [Coq](https://coq.inria.fr/) (now [Rocq](https://github.com/coq/ceps/blob/coq-roadmap/text/069-coq-roadmap.md#change-of-name-coq---the-rocq-prover)), [Agda](https://agda.readthedocs.io/en/latest/getting-started/what-is-agda.html), [Idris](https://www.idris-lang.org/), etc. However, in the last weeks, I saw that Lean, specially at the version 4, is a very capable and developed language for interactive theorem proving with a very passionate community, and proving all the theorems of this post was a fun exercise to see what I could do in the language. In the future, I hope to learn more about Lean and even start to prove things that are relevant for projects that I will be working.

If you want to see the full code, I recommend to see the [gist](https://gist.github.com/juanbelieni/7c5604cb3e4c4454ec96aa2e5dafda41/) I created. I will be updating it if I find simpler or more elegant proofs for the theorems (because I don't know if I will update this blog post with the modifications).
