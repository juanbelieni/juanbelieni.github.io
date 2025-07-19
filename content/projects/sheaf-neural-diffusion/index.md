---
title: Sheaf Neural Diffusion
summary: "
  _André Ribeiro, Ana Luiza Tenório, Juan Belieni, Amauri H. Souza, Diego Mesquita_\n\n
  Sheaf diffusion has recently emerged as a promising design pattern for graph representation learning due to its inherent ability to handle heterophilic data and avoid oversmoothing. Meanwhile, cooperative message passing has also been proposed as a way to enhance the flexibility of information diffusion by allowing nodes to independently choose whether to propagate/gather information from/to neighbors. A natural question ensues: is sheaf diffusion capable of exhibiting this cooperative behavior? Here, we provide a negative answer to this question. In particular, we show that existing sheaf diffusion methods fail to achieve cooperative behavior due to the lack of message directionality. To circumvent this limitation, we introduce the notion of cellular sheaves over directed graphs and characterize their in- and out-degree Laplacians. We leverage our construction to propose Cooperative Sheaf Neural Networks (CSNNs). Theoretically, we characterize the receptive field of CSNN and show it allows nodes to selectively attend (listen) to arbitrarily far nodes while ignoring all others in their path, potentially mitigating oversquashing. Our experiments show that CSNN presents overall better performance compared to prior art on sheaf diffusion as well as cooperative graph neural networks.
  "
date: 2025-07-01
tags:
- publication
- machine learning
externalUrl: https://arxiv.org/abs/2507.00647
---
