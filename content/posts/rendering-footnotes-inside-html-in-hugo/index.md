---
title: Rendering footnotes inside HTML in Hugo
date: 2025-07-18
tags:
- software
---

While using Hugo, I've encountered this frustrating limitation when trying to add footnotes inside HTML elements, where they do not render properly. This problem is related to the default Markdown renderer, Goldmark, which doesn't support this functionality, breaking what would otherwise be valid Markdown syntax. The fix is surprisingly straightforward. You just need to configure Hugo to use Pandoc instead of Goldmark as your Markdown renderer. Here's how:

First, add this to your Hugo configuration file:

```toml
[markup]
defaultMarkdownHandler = "pandoc"
```

Since Hugo needs to execute Pandoc, you'll need to add it to the security allowlist. Update your security configuration:

```toml
[security]
[security.exec]
allow = [..., '^pandoc$']
```

You can find the default `security.exec.allow` here: <https://gohugo.io/about/security/#security-policy>. Make sure you have the Pandoc executable available in your `$PATH`. Besides that, if you are using GitHub actions, make sure to install it before building your website by adding the following step in your workflow file:

```yaml
- name: Install Pandoc
  run: |
    sudo apt-get update
    sudo apt-get install -y pandoc
```

<p align="center">This is an example of using footnotes[^example] inside a centered `p` tag.</p>

A minor side effect is that the Pandoc highlighting styles are not included by default in Hugo. To add them, I rendered a dummy Markdown file with Pandoc to extract the CSS styles. You can find the CSS file I extracted [here](https://github.com/juanbelieni/juanbelieni.github.io/blob/main/assets/css/pandoc-highlighting.css).

[^example]: inside a centered `p` tag.
