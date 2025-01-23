---
title: Exploratory Analysis of SAE Features in Multilingual Contexts
summary: Recent research from Anthropic suggests that Sparse Autoencoder (SAE) features can be multilingual, activating for the same concept across multiple languages. However, if multilingual features are scarce and not as good as monolingual ones, SAEs could have their robustness undermined, leaving them vulnerable to failures and adversarial attacks in languages not well-represented by the model. In this post, I present findings from an exploratory analysis conducted to assess the degree of multilingualism in SAE features.
date: 2025-01-11
tags:
- ai-safety
- visualization
chart: true
math: true
draft: true
---

Recent research from Anthropic[^scaling] suggests that Sparse Autoencoder (SAE) features can be multilingual, activating for the same concept across multiple languages. However, if multilingual features are scarce and not as good as monolingual ones, SAEs could have their robustness undermined, leaving them vulnerable to failures and adversarial attacks in languages not well-represented by the model. In this post, I present findings from an exploratory analysis conducted to assess the degree of multilingualism in SAE features.

{{< alert circle-info >}}
This blogpost is part of my project completed during the [AI Safety Fundamentals Alignment Course](https://course.aisafetyfundamentals.com/alignment).
{{< /alert >}}

## Preliminaries

### Sparse autoencoders

SAEs are a specialized form of autoencoders that generate a sparse representation of vectors. This process typically involves learning two functions, $f_\text{enc}: \R^{n \times m}$ (encoder) and $f_\text{dec}: \R^{m \times n}$ (decoder), where $m$ denotes the number of features, with $m$ being significantly greater than $n$[^gated-saes]. More specifically, the decoder is defined as $f_\text{dec}(\mathbf{f}) = x_\text{dec} + \sum_{i=1}^m f_i \mathbf{d}_i$, where $\mathbf{f}$ is the vector of features and $\mathbf{d}_i$ denotes the feature directions.

{{% figure
    src="https://adamkarvonen.github.io/images/sae_intuitions/SAE_diagram.png"
    caption="Diagram of the SAE architecture. Source: Adam Karvonen[^intuitive-saes]."
%}}

During the learning phase, the SAE is encouraged to accurately reconstruct the original vector by minimizing the L2 loss associated with the difference between the reconstruction and the original. Additionally, it aims to achieve this using the fewest number of features possible by minimizing the L1 loss on the features. This trade-off between accurate reconstructions and sparse features is balanced through a sparsity coefficient on the L1 loss, defined as a hyperparameter.


### Parallel corpora

Parallel corpora are datasets consisting of aligned text pairs in two or more languages, enabling direct mapping between linguistic units across languages. Formally, a parallel corpus can be represented as a set of tuples, $\{ (s_1, t_1), (s_2, t_2), \dots, (s_k, t_k) \}$, where $s_i$ and $t_i$ denote sentences or phrases in source and target languages, respectively. These datasets are critical for tasks like machine translation and cross-lingual transfer learning. An example of parallel corpora is the FLORES-200[^flores-200], which includes sets of translations for over 200 high- and low-resource languages and will be utilized for extracting sentences for this exploratory analysis.

## Setup

I analyzed two SAEs available in the [SAELens](https://jbloomaus.github.io/SAELens/sae_table) library: `gpt2-small-res-jb` (trained on GPT-2 Small’s residual stream) and `pythia-70m-deduped-res-sm` (trained on Pythia-70M’s residual stream). The GPT-2 SAE has a dictionary size of 24,576 and operates on the `hook_resid_pre` activation at each of the model’s 12 layers, while the Pythia SAE uses 32,768 features and targets the `hook_resid_post` activation across its 6 layers.

The analysis covered 12 languages from the FLORES-200 dataset: English, German, Russian, Icelandic, Spanish, Portuguese, French, Chinese, Japanese, Korean, Hindi, and Arabic. This selection balances script diversity (Latin, Cyrillic, Hanzi, Hangul, Devanagari, Arabic) and resource availability, ranging from high-resource languages like English to medium-resource ones like Icelandic. Parallel sentences from the FLORES-200 dev split were used, ensuring direct comparability between language pairs. For tokenization, I employed each base model’s native tokenizer.

Activations were computed using TransformerLens to extract residual stream outputs, with SAE reconstructions generated via the SAELens library. For each language and layer, I recorded three metrics: 1) the total activation magnitude per feature, 2) the activation frequency (the number of tokens where a feature was activated), and 3) the reconstruction MSE.

## Exploratory analysis

Due to the higher availability of English texts in the training phase of most language models, tokenization tends to produce fewer tokens for sentences in English, while generating many more tokens for other languages, especially those that use a different writing script.

Below you can see this behavior for both models, where English and languages that uses Latin script have fewer tokens produced by the tokenizer. To account for the extra number of tokens produced by the tokenizer, I will normalize some metrics by the number of tokens produced for each language.

{{<
  chart
  id="lang-token-count-gpt2"
  chart="eJydlUuPmzAQx+/7KRDqMSF+8DC5VVXb7UNV1R56qKpqCAbcBTvFJpvVKt99DSSEbtoKcgHsvz2/GZuZebxxHPeF3hS8AnftuIUxW71erXY8By8XpmgST6hVv6CbXZbC8NUu8AjysPdLK+kuWiMbJTORWxuPdmTHO8Hvh1GvGyEb1ehbLvLCWI0itLiUv4nUFL3aiQf7PHSIFAycARIq3rrczi5TyCCiGSQxZBhnNIQwAoJInCCIw5i5fxjR3OizoWkG1s73o6+nkOzWEmQbsvuW1xX0B3FUKpXyspXyrSFjQf406o7Llo9pQDGJY+Yf5cPi34hbIVMxl+BHiPkxJuEUwgdV8/lBUBzTIIr8iExAfFa1afKGaz77rAhmlKKQTInkTc3lppiPCHzEWISmIF7LvBR6NiOkJMSI4XAC4usW5BUIG0ZAcEyO6fN/xnuwkGuug0V+ELA4mhLIq0Jcw7DZF2AWEDYlkJc1JGIzGxGF9qdCbFJ+fGm0FlckSOhTihmZlCDvNtx+pvMjwQFF9srROZLu/WOoezYjVCrkqELvx+UZ9kKPxnYmU7amtWXa9bD73HU3E7xMW3HwYZCMMGVXmT81VcJrR2XOxZKHbbfidwO27BswYsd7xpHgPoydG2DdMQ1WtK0m7exy/xf4R7u0gZxfQqWqhITSfdZdilNb6noR2F+27jtbBfXd+dROVhKoz03l/tizRltvDk//j7s4"
  caption="Number of tokens generated by the GPT-2 tokenizer for all the sentences in each respective language."
  height="20rem"
>}}

{{<
  chart
  id="lang-token-count-pythia"
  chart="eJydlU2PmzAQhu/7K5DVY0L8gcHkVlVttx+qqvbQQ1VVBhxwF+wUm2yiVf57DUmAblqJcAHs18wzY49nnu48D7wwaSEqDtYeKKzdmvVqtRM593NpiybxpV6dFnSzy1JasdpRH0Mf+b+MVmDRGkm12sjc2XhyIzfeSfHYj066larRjbkXMi+s0wiEi2v5m8xscVI78eiexw6RccsHgOKVaF1uZ5cUhkykYRSTMN1gjokQCWWUEEoSkmYC/GXECGsGQ9MMrL3vZ18vIblfS67akMFrlZfSFGAxSJXORNlq24MtJB9L6qfVD0K1LjAWhSimLDirx8X/IS9rnsj0dgamEYbYBRNOgLwqpBJG3E5BDDGCY8jYBMpnXdsmb+aBAhLGASZkSjhvRV1xNQNCozAgNEJ4AuRLY4ycQ8EEMXf4NJ5CeZcK95nNyQCXYTBgOCBTOF+3XM3KZUQhDBGkIZxA+aBrMWfLCGQumSMIp6TZm1qodFYkiFGI2KRcvpfuUG5nBDCOGKHTAnnP3aHMvJZxTDFDQ4p17x99PXQ7pDOpRpV7Py7bfC/NaOxmNtpdqbZ8Ax+B576DjRRl1oq9D71kpS27iv2pqRJRe3rjXS05bLsVvxvu2oHlVu7EiXEmgMPYuR7W7VNvxbjq0s4u9/+Af3RLG56La6jSlVS8BM+6TnFpV12P4q481qeOV/H6Ydi1i5WE10OzeTz3stGvd8c/YcDHmg=="
  caption="Number of tokens generated by the Pythia tokenizer for all the sentences in each respective language."
  height="20rem"
>}}

The number of monolingual features, which I will define as features that activate more than 50% of the time for one specific language, is also presented below. Notably, GPT-2 exhibits a high number of English monolingual features, particularly in its last layers. In contrast, the monolingual features in the first layers are dominated by languages with different writing scripts. This distinction indicates that the latent space in GPT-2's initial layers is structured more around grammatical properties than semantic ones, and the SAE captures this characteristic.

{{<
  chart
  id="mono-feat-langs-gpt2"
  chart="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"
  caption="Number of latents that activates more than 50% of the time for one specific language in GPT-2."
  height="30rem"
>}}

In Pythia, a similar behavior is observed, where English monolingual features are more prevalent in the last layers. However, the overall number of monolingual features is significantly reduced, with a noticeable dip in the middle layers. Additionally, languages such as Japanese, Korean, and Hindi exhibit a similar pattern to English, with more monolingual features concentrated in the final layers.

This suggests that the distribution of monolingual features in SAEs can vary widely, influenced by factors such as the tokenizer, the model architecture, and the dataset. This last dependency is highlighted in Kissane et al.[^sae-dataset-dependent], where they show that the performance of an SAE in a specific task is influenced by the dataset. In future work, something similar could be done with the problem presented in this post, by training an SAE on a monolingual corpus and another on a multilingual corpus and comparing them.

{{<
  chart
  id="mono-feat-langs-pythia"
  chart="eJy1Wk1v2zgQvedXCEKPqaNPy8qtKLbb/TgstoceFsWClmmbW4n0SpTToMh/LyV/SI4fiQoDXxKLlPj4OPNmhhK/33me/6Yptrxi/qPnb7XeNY8PD3u+YbON0Nt2ORPq4XBD3/q2FJo/7NNZFMzC2X+Nkv59N0ih5FpszBjfzZW53gv+dL469GshW9U2H7nYbLXpi4Pg/rr7s1jp7aG373wxf196iBXTbACQrOLdlLvWt3lSFEme5mHI09U6XS/DLEly8ztfM5bmS/9ikIbrZhjo5wZ49P45zvVEqZ91KzsmURreD60lk91C+O9qthSFf9HzzGvTlY7aKrXiZXf77llvBfOPPS/3drgwTQHcr7yumERwMQ0uXgC0v9umERguocGlUQTwfmc7JnnDb7CcUYKs98ngiWZ7A4LzIAN4vxXc/FxhhwloiFkAAP9QNccGDIkGXMST1EAkF0Lz/aVq3W5ai8cQGcYBYvhRGPPdgmCQT/NPot7naD2t5IhgiwSAucROxEuR9t5vxY3g5shRHLGT6JhJiGL1h5rLAnoKMXLGIfJMOxw1M2QI7he5KS1CiIj0YFp3BmoiwwimBncso0JGqJiwJwdqMIsRQ5fgqdkW+YxD8ES4JEf8rNGTWgkuplWCxPASZii8OBaTSG8xrW4hyj2DucG+mGQlIM+0l0lE20WwinCHFmLyC6OpWqf65xw5jN2CRPdMw/k0ORA9JkrRzsiuByK9BNUuDnZE+UUJWk1HrURczRyFTkdVTaQXziNUTTiqF2ImypD5HPyI2ssyVMk78IjmW+TIXRzLSQxmESzl7bUueYuJUq2z9qRGMxSs7emI6p0Jkp87HRE9JkaIdoLU5JelE3crRHpz5DCuZEstlyZu/qjWi+KJgqfW1nDn4PZQIiR8T2dfUaoBUTVh1wM1/8WInHVjRK4Ekdid4ZOKmCL9WfkRVzMJED+X2qnRBWUHR3a/xc7PUXve5IWufeNAfeeCKkFHpUt954kqMwccVekBMp5Te0TExSTpEY0XwrznpEctJWLkne5MRLZhhgTvyLZEBcJq3uGj5E+oSBP2VHuLrw72jTsRLUfhxY5G1QOsq+2x82c8s///5e700d5YRa2EHB0vKFSpan90vmAteLnqRuoncILwm4KVfHSfaVqpignpDx/0+9arusdD+cZDEvCA43hgBbzrmOThwOHBVO4BI3qWOOAh8XhDxj63fRlZoz/m0R+qqM0KLdXTlfl9LXS/nv6fZplbthkwff2863ukqoRk5eHZ45P+t7Gt2DfRXNpkz0pD4JVNgvHMw/FFNL6IxxfJ+CIdWF4RGflL55aI4GX7kd3/LZPmHqbFnl9SfIbueFDJ9fDvX7Xbhz+rYHs6ONOfljEWOs7Pr1j9dZCGkJrXO1Uy3Y9YKam0kidD+aV5zrTruuXHlhM2M741HJTZsZpVg0nOzJbGhft14xtufp0ZnM7j9M/9G40kyEte6Et798vz2t4H6ULPPE1xpwy7yyjR/e1v9XXNZLNWdXU96bUoNa8v59BPdDxjy7BPxwNJo1W/e/kBaY9DBw=="
  caption="Number of latents that activates more than 50% of the time for one specific language in Pythia."
  height="30rem"
>}}

Another potential visualization is presented below. I plotted the variance in the frequency of features across all languages. As shown, the layers with high variance correspond to those with a greater number of monolingual features, and the overall shape remains the same. This also suggests that SAEs do not encode loads of both monolingual or fully multilingual features, with few intermediate multilingual features. To further validate this, we can plot the distribution...

{{<
  chart
  id="feat-count-var-gpt2"
  chart="eJydlc1u4jAQx+88BYp6pMGfY5sn2MOedw+ramWCIW6DwyYOLap493UCBENzIM0h0X/G/s1kPBp/TqbT5KnOcrPVyWKa5N7v6sV8vjcbnW6sz5tlasv5aUFnfS6sN/M9TwlKcfpaly6ZtZCsdGu7CYzPoILeW/Peq5PfW9eUTf3D2E3ug48iNPvq/m1XPj95O+cxvI9diJX2+hrA6a1pU26tz7Baci3RGjIhtFgzRrVmwJdyKbOMCpHcQGrj6yvoMcBi+uec6+WXwtZCe+P836xswnuvq7AKpYgwxRUTGAkQBBSms3jHwbTL6Nl0nD1M5QRAMQwUJApoGKCS8VSJgFApQ7Wl4qAGoHI0lCIQSBCiQgUJAzIAxeMzFRyIpEphRKVQaqiqbDw15Ei5QByYkjzEGKCq8VRQhArFSEgTGBqqKnynAJQiwWQAIkrkUFnFeCrjGGHMqeSIc86GqOgbuRIpuOQASOLQAwNQPr6tJMLAgWPGQtOiISge31eUKhoaKpwWC71Ahs4K9wXovi/9MDEuK1fWRWPvI555+sPWkW6noi4aU0fDpH3QLBI4FiQWNBYsFjwWEAsRCxkLdRP0NgXci5f7ciZra4pVO3dPxent3vqim8c/7+yHXWf+1+gw4b32dm+SScRMDnHJIvzdYX2N9EtXVrvMPBSsP7P8cv10d4627pxtstXV2/UgrfOm2pVtGu3abelKX7pLrKQI+4LdV405Wy6xdWX09bp5P99mUbDJ8T/687xQ"
  caption="Mean variance in the frequency of features across languages for GPT-2."
  height="20rem"
>}}

{{<
  chart
  id="feat-count-var-pythia"
  chart="eJyVlMuOmzAUhvfzFBHqkiG+4FueoIuu20U1qgx4gltip2CYiUZ599oEiJthkYBE8p9jf+ciH388bTbJl66s1UEmu01SO3fsdtvtoPYy22tX90Wm7fayYLQ+N9qp7UAyBDKY/e6sSdIAKa151XvP+PDK60Grt0Vd/E6b3vbdV6X3tfM+DED62f1DV66+eEfn2X/PY4hKOnkNYORBhZSD9ZkKKTArOa+KoiwII4gxAikTkhccM5X8B+mU666g+wC7zc8p17kkv7WRThn3q7S9/w6y9atABgAlhGGECEPCI3KaxjtOKiyDk+mc3k3FgkNIKPJARjHCK1T0OJVBiBlHlHPBCMb5CjV/nJpjQolAOWICC8joWgvww1jIUMiVQe5fCleY4HEm5IIwQADMfV/RWv1kho6/L8tRUqa0lTbRoX+PT7x8112kw0zIpldddJTCA9JIwFigWOBY5LEgy/+X2+qTV62aKkzJpZbF7rRrxun5dmM/HUfz3176eXTS6WGcnYWZnOISI/xNbz9H+i5bLU2p7gq29LieL4vxhpDaTNkmB9n+uTZeG6faow1phLUHa6yzZo6VNH6ft7u2V5Nlji1bJa+Xw9t090TBns7/AKjGPaA="
  caption="Mean variance in the frequency of features across languages for Pythia."
  height="20rem"
>}}

[^scaling]: Templeton, et al., "Scaling Monosemanticity: Extracting Interpretable Features from Claude 3 Sonnet", Transformer Circuits Thread, 2024, <https://transformer-circuits.pub/2024/scaling-monosemanticity>.

[^sae-dataset-dependent]: Kissane, Connor, et al., “SAEs Are Highly Dataset Dependent: A Case Study on the Refusal Direction.” Lesswrong.com, 2023, <https://www.lesswrong.com/posts/rtp6n7Z23uJpEH7od/saes-are-highly-dataset-dependent-a-case-study-on-the>.

[^gated-saes]: Rajamanoharan, Senthooran, et al. “Improving Dictionary Learning with Gated Sparse Autoencoders.” ArXiv.org, 2024, <https://arxiv.org/abs/2404.16014>.

[^intuitive-saes]: Karvonen, Adam. “An Intuitive Explanation of Sparse Autoencoders for LLM Interpretability.” Adam Karvonen, 11 June 2024, <https://adamkarvonen.github.io/machine_learning/2024/06/11/sae-intuitions.html>.

[^flores-200]: NLLB Team, et al. “No Language Left Behind: Scaling Human-Centered Machine Translation.” ArXiv:2207.04672 [Cs], 25 Aug. 2022, <https://arxiv.org/abs/2207.04672>.
