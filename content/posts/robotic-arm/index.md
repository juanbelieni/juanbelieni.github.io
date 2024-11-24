---
title: "Simulating a seeker robotic arm in Python"
date: 2023-01-27
tags: ["simulation", "math", "python", "programming"]
math: true
aliases: /blog/robotic-arm
---

The robotic arm built in this article is a simple n-joints arm that can be rotated in two directions. It will be simulated in Python using the [Pygame](https://www.pygame.org/) library.

The objective here is to use concepts of optimization to make the arm follow a moving target (in this case, the mouse cursor).

<!--more-->

## The robotic arm

![GLaDOS](https://i.imgur.com/V15B9ja.gif)

The robotic arm is a simple n-joints arm that can be rotated in two directions, i.e., its state is defined as $s = \\{ \theta_1, \cdots, \theta_n \\}$, where $\theta_i$ is the angle of the $i$-th joint. Each segment of the arm will be represented by a line of length $l_i$, where $l_i$ is the length of the $i$-th segment.

The control of the arm is made by passing a input vector $u = \\{ \omega_1, \cdots, \omega_n \\}$, where $\omega_i$ is the angular velocity of the $i$-th joint. The control is applied to the arm by updating its state, i.e., $s \leftarrow s + u \Delta t$.

The position $P = (x, y)$ of the end of the arm is given by the following equations:

$$
\begin{align*}
x &= \sum_{i=1}^n l_i \cos\left(\sum_{j=1}^i \theta_j\right), \\\\
y &= \sum_{i=1}^n l_i \sin\left(\sum_{j=1}^i \theta_j\right).
\end{align*}
$$

## Defining the optimization problem

The objective of this optimization problem is to minimize the distance between the position of the end of the arm $P$ and the target position $T$. First, we define the cost function $E(s, T)$ as the squared distance between $P$ and $T$:

$$
E(s, T) = \left\lVert P - T \right\rVert^2.
$$

With this cost function, we can use a unconstrained optimization method to minimize the cost function iteratively, like the [gradient descent](https://en.wikipedia.org/wiki/Gradient_descent) method, which works by updating the state of the arm in the direction of the negative gradient of the cost function:

$$
s \leftarrow s - \alpha \nabla E(s, T),
$$

where $\alpha$ is a value that controls the step size of the gradient descent. For better convergence, we can define $\alpha$ with the line search method, which consists in finding the step size $\alpha^*$ that minimizes the cost function $E(s, T)$ by solving the following problem:

$$
\begin{align*}
\underset{\alpha}{\text{minimize}} \quad & E(s - \alpha \nabla E(s, T), T) \\\\
\text{s.t.} \quad & \alpha > 0.
\end{align*}
$$

Before we can continue to the implementation, we need to define the gradient of the cost function:

$$
\nabla E(s, T)
= 2 \begin{bmatrix}
\- (P_x(s) - T_x) \sum_{i=1}^n l_i \sin\left(\sum_{j=1}^i \theta_j\right)
\+ (P_y(s) - T_y) \sum_{i=1}^n l_i \cos\left(\sum_{j=1}^i \theta_j\right)
\\\\
\- (P_x(s) - T_x) \sum_{i=2}^n l_i \sin\left(\sum_{j=1}^i \theta_j\right)
\+ (P_y(s) - T_y) \sum_{i=2}^n l_i \cos\left(\sum_{j=1}^i \theta_j\right)
\\\\
\vdots
\\\\
\- (P_x(s) - T_x) l_n \sin\left(\sum_{j=1}^n \theta_j\right)
\+ (P_y(s) - T_y) l_n \cos\left(\sum_{j=1}^n \theta_j\right)
\end{bmatrix},
$$

where $P_x(s)$ and $P_y(s)$ are the $x$ and $y$ coordinates of the end of the arm given by the state $s$, respectively.

## Implementation and results

First, I implemented the [robotic arm](https://github.com/juanbelieni/robotic-arm/blob/master/src/robotic_arm.py) class, which is responsible for the simulation and drawing of the arm:

```python
class RoboticArm:
    angles: np.ndarray
    lengths: np.ndarray
    ...
```

Inside the [main file](https://github.com/juanbelieni/robotic-arm/blob/master/src/main.py), it is defined a method to calculate the gradient of the cost function:

```python
def calc_grad(arm: RoboticArm, T: np.ndarray) -> np.ndarray:
    n = arm.size
    grad = np.zeros(n)

    for k in range(n):
        Px, Py = arm.end_point
        Tx, Ty = T

        for i in range(k, n):
            l = arm.lengths[i]
            sum = np.sum(arm.angles[: i + 1])
            grad[k] += -(Px - Tx) * l * np.sin(sum) + (Py - Ty) * l * np.cos(sum)

        grad[k] *= 2

    return grad
```

For stability reasons, the gradient is normalized inside the simulation loop. The full implementation of the robotic arm can be found in my GitHub repository: [juanbelieni/robotic-arm](https://github.com/juanbelieni/robotic-arm).

The following gif shows the robotic arm moving:

![Robotic arm](https://i.imgur.com/49BNAeh.gif")

I confess this robotic arm is not very realistic, but it is a good example of how to use optimization to control a system. If you want to contribute to this project, feel free to open a pull request or a issue in the GitHub repository.

## Acknowledgements

This small project was inspired by the mini-course given by [Prof. Gennaro Notomista](https://www.gnotomista.com/), so I recommend to check his work.
