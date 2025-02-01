---
title: Exploratory Analysis of Multilingual SAE Features
summary: Recent research from Anthropic suggests that Sparse Autoencoder (SAE) features can be multilingual, activating for the same concept across multiple languages. However, if multilingual features are scarce and not as good as monolingual ones, SAEs could have their robustness undermined, leaving them vulnerable to failures and adversarial attacks in languages not well-represented by the model. In this post, I present findings from an exploratory analysis conducted to assess the degree of multilingualism in SAE features.
date: 2025-02-01
tags:
- ai-safety
- visualization
chart: true
math: true
---

Recent research from Anthropic[^scaling] suggests that Sparse Autoencoder (SAE) features can be multilingual, activating for the same concept across multiple languages. However, if multilingual features are scarce and not as good as monolingual ones, SAEs could have their robustness undermined, leaving them vulnerable to failures and adversarial attacks in languages not well-represented by the model. In this post, I present findings from an exploratory analysis conducted to assess the degree of multilingualism in SAE features.

_This blogpost is part of my project completed during the [AI Safety Fundamentals Alignment Course](https://course.aisafetyfundamentals.com/alignment)._

## Introduction

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

The code for this project can be found at <https://github.com/juanbelieni/aisf-project>.

## Exploratory analysis

### Number of tokens

Due to the higher availability of English texts in the training phase of most language models, tokenization tends to produce fewer tokens for sentences in English, while generating many more tokens for other languages, especially those that use a different writing script.

Below you can see this behavior for both models, where English and languages that uses Latin script have fewer tokens produced by the tokenizer. To account for the extra number of tokens produced by the tokenizer, I will normalize some metrics by the number of tokens produced for each language.

{{<
  chart
  id="lang-token-count-gpt2"
  chart="eJydVU2PmzAQve+vQFaPCbENxia3qmq7/VBVtYceqmplwAF3wU6xyWa1yn+vIQmwm1aCXAD7mXnzZjwzTzeeB16ZtBAVB2sPFNZuzXq12omc+7m0RZP4Uq+OB7rdZSmtWO2Ij6GP/N9GK7BojaRabWTubDy5lVvvpHjoV0fcStXoxtwKmRfWYQGEi0v4h8xscUQ78OCeh44i45YPBIpXonW53V1GIYo4zVACBctCkiRxymlCw5BEG5QhBp4ZMcKawdA0A2vv58nXsyT3a8lVKxl8SIX7zGQKFgNY6UyULZpvLR4D6s7qe6FaFxAJIIYQRuEJPiz+z/KtMUZyNZcjiMIgQAxTPIHjdc2T+TIwjQKXLzZJxluVl9IUczmiAEcIMhRNoLiVLhlzCUIKWRgjPEnEm0IqYcTsQEFMECOYwQkcH/mWX0OCGA0JYTGdEqp3tVDp7GQgTELIGIVTYvVV17bJm2uUYMTcxYrwFJrvLlpX3CsnhWAUYzglJe9FXc2vQBSQAOE4ZlNkfNK1uKLIURwQSsOhyLv3r77vuSzrTKpRh96P2zPfSzNau52NdlLbNg18BF76DTZSlFkL9j70kJW27Drzl6ZKRO3pjXdx5HHbnfjTcNf2LbdyJ44cJwbwOHauJ+ti1Fsx7l61u8v9P8g/u6MNz8UlqdKVVLwEL6ZLcR5L3Szirrzr42SreH0/RO1sJeH1MFQeTjNr9OvN4S9Dnbp+"
  caption="Number of tokens generated by the GPT-2 tokenizer for all the sentences in each respective language."
  height="20rem"
>}}

{{<
  chart
  id="lang-token-count-pythia"
  chart="eJydlU2PmzAQhu/7K5DVY0JsjMHkVlVttx+qqvbQQ1WtDBhwF+wUm2yiVf57DUkIu2klL5cQ+zXzzIyHmccbzwOvdFbxhoG1BypjNnq9Wm15yfxSmKpLfaFWxwPD7rIWhq+2xA+gj/zfWkmw6I1kShaitDYe7cqut4I/jKujboTsVKdvuSgrYzUM4eJa/iFyUx3VQTzY38OAyJlhF4BkDe9d7neXNMhpgiEu8oLkPI0CHsUJxWmWY4Y5xOCJEc2NvhhyM7D2fp58PYdkX62Z7EMGr1uWigwsLkqjcl730mZvKsGmkrwz6p7L3oOAxAEMCCXRST4s/g/5vmFS6OrlFEQgjBAkEXSgfMi4/ZvPiQYlBIY0CHHgwPnIbDhc8xkYmiQkoChxwbyVZT0raZTGkQ2Ihg6Qdy2X2ayLQZRARCl1gHzrtBZMzigybDNma8wpX28qMfdWEMVBAp1iuRW2wl7OCGESU2yr2YXxSbV8TrowpPabjN0g73nbzIEgEkchJjFyuZOvqjVd2c27lhBHSRhgPHaY4flr7Ie2clUu5KRz76Ztm+2EnqztTqFsyH37Bj4Cz70HheB13oujD6NkhKmHjv2la1Leeqrwro7sN8OJPx2z48AwI7b8yDgRwH7q3AgbMjVa0TZf/e5y9w/4Z3u0YyW/hkrVCMlq8GzqVOdxNcwoZj+P9jjxGtbeX7J2tpKy9jJsHk6zbPLqzeEvN8HIAA=="
  caption="Number of tokens generated by the Pythia tokenizer for all the sentences in each respective language."
  height="20rem"
>}}

### Monolingual features

The number of monolingual features, which I will define as features that activate more than 50% of the time for one specific language, is also presented below. Notably, GPT-2 exhibits a high number of English monolingual features, particularly in its last layers. In contrast, the monolingual features in the first layers are dominated by languages with different writing scripts. This distinction indicates that the latent space in GPT-2's initial layers is structured more around grammatical properties than semantic ones, and the SAE captures this characteristic.

{{<
  chart
  id="mono-feat-langs-gpt2"
  chart="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"
  caption="Number of features that activates more than 50% of the time for one specific language in GPT-2."
  height="30rem"
>}}

In Pythia, a similar behavior is observed, where English monolingual features are more prevalent in the last layers. However, the overall number of monolingual features is significantly reduced, with a noticeable dip in the middle layers. Additionally, languages such as Japanese, Korean, and Hindi exhibit a similar pattern to English, with more monolingual features concentrated in the final layers.

This suggests that the distribution of monolingual features in SAEs can vary widely, influenced by factors such as the tokenizer, the model architecture, and the dataset. This last dependency is highlighted in Kissane et al.[^sae-dataset-dependent], where they show that the performance of an SAE in a specific task is influenced by the dataset. In future work, something similar could be done with the problem presented in this post, by training an SAE on a monolingual corpus and another on a multilingual corpus and comparing them.

{{<
  chart
  id="mono-feat-langs-pythia"
  chart="eJy1Wstu4zYU3ecrBGGWGUcP6+HsBoO208eiaBddFIOClhmbrUS6EuVMMMi/D00/JMeHxAgX3jghKfHw3nvugxS/3gVB+K6rNrxh4WMQbrTedo8PDzu+ZrO10Jt+ORPq4fCA7X1fC80fdtksiWbx7N9OyfB+P0ml5JNYmzm+mpZp7wR/PrcO41rIXvXdJy7WG23G0ii6vx7+S6z05jBqB1/N76uFWDHNBgDJGr5f8r73fZRmcbyIq5IvqyjN8+WKpQmPq7xcxvGqLMOLSTquu2Gi75vgMfj7uNaTSHbVvbSSJGl+P3TXTO41Ef4g17XoNuHF0AtvzVg26mvUitf757cveiNYeBx5vXcDxkUJ8D5uhOQdvwFeViymyZfQ8HIE5xFvTlRnHgG8n3jbMHkDbeZRAeB+rrj5dyUqhBjREMs5APyFbZlLoSkNL5nHAPBPg+fgC9GA8yibKCBRoXkK8P7ou05gxsQ0uCIBcB9atsRsIXqfiYVT+Um0X4HU6aELUZ0pYotbnURnyEoknRuOSM1ijqT7XbW6X/e38YYFyn4eb6BmoxjhedIDVaMFCp8eehLx0ggR5pMwzncTNFRLeL2dXE1MMx/R/wqU3H9VLb9JqE5Q7PT4AlG4Egnn0SVRujhFtvMlWmJmgFxxx05qHREjX/ix5bK6SRkPE5G77iTm9QVC84QxIlwcoSreg0d0hTiZyk1qGQHjtNt85F0KjC2eXRgRMIF1oNv5iN6QQL74CxciZXLk7j7GEF0iS1Ah7wOk6jRDgO7kRw1ocN/nNyE1I8GzAj8kVcoIJV1vxUQNpdm0REGNpCnSqdvxiSYskRc6y11iUMtRkvAkJSJX0hip0l1RUDfSsF5yE4W4d0jgSZbf+agFIdqLeeprquelKMf7JaRCltOcnbphSRCcO0UQKTNfIMo4vZ2a/+BBndv9qMkIstMNRy1fULZ1qpIINkea9Ow0yY6HkqxTOGoKmnZGQJUtRy7nLSDIxJyUY4nyJfOJB4LEmBIX2cTvU9TvKfDE04NHPcKaWEUQxYNFhNsbqNUmFM7rDUTEFDmDh57EkmWBwrRbndRjgqhA5vOQk/pxCsVONze/J7bYv5/vTh/tzVRqJeToekGlatWGo/sFT4LXq/1MdgEniLCrWM1Hz5mulWqYkOHwQd/2Xm1uApTcAqTHAEgbgIItuA64AeZ5AM8EAkCawFGLBojPwbDROfd9HlnDXvOwlypao6Gler6yfqiFtvoMfzNq7tl6wAz1y9aOSNUIyerDu8c3wy9jW7Evoru0yY7VRoA3NonGK4/HjWTcSMeN+biRDVJeCTLiy56WSMDL/qN0//dMmmeYFjt+KeILpOPBSa6n//im3z392Qs2p4sz9raMsdBxfWHD2v8G1xBS83araqbtjI2SSit5MlRYm/dMv257fuw5YTPDreGizJa1rBlMcpZsaShs9cbX3Px3luB0H8e+908yckFe80pf2tuq5629D64LmXla4lYZ6S6jxP7XPhrqlsnuSbXN9aKfRK15e7kGu9Dxih3TPh8vJI20fvf6DeweQfs="
  caption="Number of features that activates more than 50% of the time for one specific language in Pythia."
  height="30rem"
>}}

Another potential visualization is presented below. I plotted the variance in the frequency of features across all languages. As shown, the layers with high variance correspond to those with a greater number of monolingual features, and the overall shape remains the same. This also suggests that SAEs do not encode loads of both monolingual or fully multilingual features, with few intermediate multilingual features. To further validate this, we can plot the distribution...

{{<
  chart
  id="feat-count-var-gpt2"
  chart="eJydlUtz2jAQx+98CsbTIzF6rR58gh56bg+dTEcxAis1NrVlkkyG7961eQniA4aDmf9K/u16d7X6nEynybcmy93GJotpkoewbRbz+c6tbbr2IW9fUl/NDxt661Phg5vvIGUkpelrU5XJrINkVbnya2R8okK98+7trA7rwZdt1TbfnV/nAdc4IbOvy7/8MuSH1X5xj89972Jpg704KO3GdSF31qcMWJatXihYTiRZMSmZXllGmMrYMmOQXEEaF5oL6D7AYvr7GOvpk/DVwgZXhj9Z1eJzZ2vcRVLCNaESJFAhiGREzOIXPly3i9KjbT+7l8oUYEzcGIoOlDF8ACvGUwVQQilwDQQABBugktFUzg3HIJURwgjJzFAGxlOZNIwjk+HHS0GGqPKBtDKtQIOURFNgQ8WC8VCNhedaYw9rA3IoUj0eiqnkoAhIYTRgOwxQzSNtxTlRQmNCCWd6qAHUeCrgCTKCSi41IUrKASob31ZEKqJYlwislBwK9YFzJQwYoShGqbDD6NC54idq//98HiauzKqlL6Ox9x7PPPvum0h3U9EWrWuiYdL9yCwSNBYsFjwWIhYQCxkLFQsdC3Pl9DoEehbPt+lMVt4Vy27uHnJztgcfin4e/7ixf2x787/W4oQPNvidSyYRM/mIUxbhb4r11dNPW3tbZu4uZ+ea5afrp79zrC+P0SYbW/+9FNKXwdXbqguj27upyipU5clXUuB7aA91646Wk29bO3u5bt6Ot1nkbLL/D4u2u64="
  caption="Mean variance in the frequency of features across languages for GPT-2."
  height="20rem"
>}}

{{<
  chart
  id="feat-count-var-pythia"
  chart="eJyVlM2O2jAQx+88BbJ6zAZ/xF88QQ89t4dqVZlgiNtg08TJLlrx7rVDCC6bAySSk/+M/ZsZa+yPxXIJvrRlpQ8KrJeg8v7YrlerXu9Vvje+6ja5cavLhMH6UhuvVz3NMcxR/rt1FmQRUjq7M/vA+Agq6N7ot0ld/N7YznXtV232lQ8+AmH22f3DbH118Q7OcxjPQ4it8uoWwKqDjilH64ugnLGdwFSjzaZAUu8ElVxIohXCmAjwH6TVvr2BHgOslz/HXK8lhaW18tr6X6XrwtirJsyCOURISMohhagoGMdFli446TiLjqZz9igUEikQogzzwGQEkxkqfpqKOCZcYI5EeBmaYcLnM+UIRSgTQnJKyFz9xfNURiknGFOOJWJhE2ao6HlqQSijEheYSyJR6IEZLLlih+/r1Eralm5rbNL072nHq3fTJjqeCVV3uk1aKT4wSwRKBU4FSUWRCjr9v97XD3ZG19t4Si61THZvfD2cnm939tNxMP/tVDiPXnnTa7BImOCUlpjg73b3c6TvqjHKlvqhYNMeV9fLYrghlLFjtuCgmj+3jTfW6+boYhpx7sFZ5529xgJ1WBfsvun0aLnGVo1Wt8vhbbx7kmCL8z9rdDza"
  caption="Mean variance in the frequency of features across languages for Pythia."
  height="20rem"
>}}

### Multilingual features

On the following tables, I present the language groups with the highest number of features that activate at least 5% of the time for each language in the group.

For GPT-2 (in the table below), we can see that the first layers have more features focused on languages with non-Latin scripts (as we have already seen), while the following layers have more features focused on languages with Latin scripts (both mono- and multilingual).

|Layer|1st|2nd|3rd|4th|5th|
|--|--|--|--|--|--|
0|Arabic, Hindi, Korean, Russian|Chinese, Japanese|Hindi, Korean, Russian|English, French, German, Icelandic, Portuguese, Spanish|Hindi|
1|Chinese, Japanese|Hindi|English, French, German, Icelandic, Portuguese, Spanish|English, French, German, Portuguese, Spanish|Japanese|
2|Chinese, Japanese|Hindi|English, French, German, Icelandic, Portuguese, Spanish|English, French, German, Portuguese, Spanish|English, French, Portuguese, Spanish|
3|Chinese, Japanese|English, French, German, Icelandic, Portuguese, Spanish|English, French, German, Portuguese, Spanish|English|English, French, Portuguese, Spanish|
4|English|English, French, German, Portuguese, Spanish|English, French, German, Icelandic, Portuguese, Spanish|Chinese, Japanese|English, French, Portuguese, Spanish|
5|English|English, French, German, Icelandic, Portuguese, Spanish|English, French, German, Portuguese, Spanish|English, French, Portuguese, Spanish|French, German, Icelandic, Portuguese, Spanish|
6|English|English, French, German, Portuguese, Spanish|English, French, German, Icelandic, Portuguese, Spanish|English, French, Portuguese, Spanish|French, German, Icelandic, Portuguese, Spanish|
7|English|English, French, German, Portuguese, Spanish|English, French, German, Icelandic, Portuguese, Spanish|English, French, Portuguese, Spanish|English, German|
8|English|English, French, German, Portuguese, Spanish|English, French, German, Icelandic, Portuguese, Spanish|English, French, Portuguese, Spanish|English, French|
9|English|English, French, German, Portuguese, Spanish|English, French, German, Icelandic, Portuguese, Spanish|English, French, Portuguese, Spanish|English, French|
10|English|English, French, German, Portuguese, Spanish|English, French|English, French, Portuguese, Spanish|English, German|
11|English|English, French|English, German|English, French, Portuguese, Spanish|English, French, German, Portuguese, Spanish|

The results for Pythia also follow what we would expect based on the previous visualizations, where the first and last layers have more monolingual features focused on English. However, the SAE for layer 2 has a surprisingly high amount of full multilingual features, with the first language group containing all the languages I tested.

**Pythia**:

|Layer|1st|2nd|3rd|4th|5th|
|--|--|--|--|--|--|
0|English|English, French, German, Icelandic, Portuguese, Spanish|English, French, German, Portuguese, Spanish|Spanish|German|
1|English, French, German, Icelandic, Portuguese, Spanish|English|English, French, German, Portuguese, Spanish|English, French, Portuguese, Spanish|English, French, German, Portuguese, Russian, Spanish|
2|Arabic, Chinese, English, French, German, Hindi, Icelandic, Japanese, Korean, Portuguese, Russian, Spanish|Arabic, Chinese, French, German, Hindi, Icelandic, Japanese, Korean, Portuguese, Russian, Spanish|English|English, French, German, Portuguese, Spanish|English, French, German, Icelandic, Portuguese, Spanish|
3|English, French, Portuguese, Spanish|English, French, German, Icelandic, Portuguese, Spanish|English, French, German, Portuguese, Spanish|English|Portuguese|
4|English|English, French, Portuguese, Spanish|English, French, German, Portuguese, Spanish|English, French, German, Icelandic, Portuguese, Spanish|English, French|
5|English|English, French|Chinese, English, Japanese|English, Japanese|English, French, Portuguese, Spanish|

## Conclusion

The exploratory analysis conducted on two SAE models (GPT-2 and Pythia) across 12 languages revealed several insights into the multilingual capabilities of SAE features. Both models exhibited a dominance of monolingual features, particularly for English, with these features being more prevalent in later layers. Conversely, features for languages using non-Latin scripts were more common in earlier layers, suggesting that SAEs may capture different types of linguistic information at different depths of the network.

The analysis also highlighted a clear layer-wise progression in feature specialization. Early layers tended to capture language-agnostic or script-specific features, while later layers became increasingly specialized for English and other Latin-script languages. This suggests that SAEs may organize linguistic information hierarchically, with lower layers encoding more general features and higher layers encoding more language-specific or semantic features.

While the study demonstrated that some features are shared across languages, the distribution of multilingual features was not uniform. Layers with higher variances in feature activation frequencies corresponded to those with more monolingual features, indicating that SAEs may not inherently encode a large number of fully multilingual features. Instead, the models appear to rely on a mix of monolingual and partially multilingual features, which could have implications for their robustness and generalization across languages.

These results highlight the importance of understanding how SAEs encode linguistic information, especially in multilingual contexts. If multilingual features are scarce or less effective than monolingual ones, SAEs may struggle with robustness and generalization across languages, potentially making them vulnerable to failures or adversarial attacks. This raises critical questions about the design of SAEs for multilingual models and the need to ensure that they can effectively capture concepts across diverse linguistic representations.

## Future Work

1. **Investigating dataset influence.** The distribution of monolingual and multilingual features observed in this study may be influenced by the training data of the base models. For instance, GPT-2, being trained primarily on English text, exhibits a strong bias toward English features. Similarly, Pythia, which may have been trained on a more diverse dataset, shows a different distribution of monolingual and multilingual features. Future work could involve training SAEs on monolingual versus multilingual corpora and comparing the resulting feature distributions. This would help clarify whether the observed patterns are inherent to the SAE architecture or are shaped by the training data.

1. **Exploring language groupings.** The language groupings identified in this study (e.g., Latin-script languages vs. non-Latin-script languages) suggest that SAE features may cluster around linguistic or typological similarities. Future work could explore this hypothesis further by analyzing whether languages with similar grammatical or typological properties share more features. For example, languages with similar word orders or morphological structures could be expected to share more features in certain layers. This could involve expanding the analysis to include more diverse language families and testing for correlations between feature sharing and linguistic properties.

1. **Adversarial robustness in multilingual contexts.** The findings of this study raise concerns about the robustness of SAEs in multilingual contexts. If certain languages are underrepresented in the feature space, models may be more vulnerable to adversarial attacks or failures in those languages. Future work could investigate the susceptibility of SAEs to adversarial perturbations in underrepresented languages and explore strategies for mitigating these vulnerabilities. For example, techniques such as adversarial training or feature regularization could be used to promote more balanced feature distributions across languages.

1. **Developing metrics for multilingual feature evaluation.** The analysis in this study relied on simple metrics such as feature activation frequency and monolingual feature counts. While these metrics provided valuable insights, they may not fully capture the complexity of multilingual feature sharing. Future work could involve developing more sophisticated metrics for evaluating the degree of multilingualism in SAE features, such as multilingual feature density or cross-lingual feature alignment. These metrics could help quantify the extent to which features are shared across languages and identify areas where models may be underperforming.

[^scaling]: Templeton, et al., "Scaling Monosemanticity: Extracting Interpretable Features from Claude 3 Sonnet", Transformer Circuits Thread, 2024, <https://transformer-circuits.pub/2024/scaling-monosemanticity>.

[^sae-dataset-dependent]: Kissane, Connor, et al., “SAEs Are Highly Dataset Dependent: A Case Study on the Refusal Direction.” Lesswrong.com, 2023, <https://www.lesswrong.com/posts/rtp6n7Z23uJpEH7od/saes-are-highly-dataset-dependent-a-case-study-on-the>.

[^gated-saes]: Rajamanoharan, Senthooran, et al. “Improving Dictionary Learning with Gated Sparse Autoencoders.” ArXiv.org, 2024, <https://arxiv.org/abs/2404.16014>.

[^intuitive-saes]: Karvonen, Adam. “An Intuitive Explanation of Sparse Autoencoders for LLM Interpretability.” Adam Karvonen, 11 June 2024, <https://adamkarvonen.github.io/machine_learning/2024/06/11/sae-intuitions.html>.

[^flores-200]: NLLB Team, et al. “No Language Left Behind: Scaling Human-Centered Machine Translation.” ArXiv:2207.04672 [Cs], 25 Aug. 2022, <https://arxiv.org/abs/2207.04672>.
