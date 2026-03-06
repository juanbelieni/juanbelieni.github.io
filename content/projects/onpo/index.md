---
title: Orthogonal Gradient Projection for Continual LLM Unlearning
location: "RSI @ ICLR 2026"
summary: "
  _Juan Belieni, Ana Carolina Erthal, Eliezer de Souza da Silva, Diego Mesquita_\n\n
  Machine unlearning enables the removal of specific knowledge from trained models without full retraining. While effective methods exist for single deletion requests, handling sequential requests in large language models (LLMs) remains underexplored. In this setting, we observe that gradient interference between successive unlearning steps degrades prior objectives. We propose ONPO (Orthogonal Negative Preference Optimization), which projects each step's update onto the orthogonal complement of a low-dimensional subspace spanned by cached gradients from previous unlearning requests. This preserves prior unlearning objectives with minimal per-step overhead. On the TOFU benchmark, ONPO achieves a better trade-off between forgetting quality and model utility than existing methods.
  "
date: 2026-03-05
tags:
- publication
- machine learning
- ai-safety
externalUrl: https://openreview.net/forum?id=lb6Ce20kl5
---
