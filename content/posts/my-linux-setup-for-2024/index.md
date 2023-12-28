---
title: 'My Linux Setup for 2024'
tags:
- Linux
date: 2023-12-26
---

Throughout 2023, I did a lot of changes on my Linux setup, the major one being migrating most of my workflow into one more focused on terminal-based softwares. Here I will try to document what changes I've made and what I pretend to change in the next year.

## Distribution

At the end of 2022, I migrated to Arch Linux, and I think I will continue to use it this year, since I don't have the time to distro hop in the next months. However, If I would change, maybe I would try some Arch-based distro, Void Linux, NixOS or Gentoo. But the main reasons I will continuing using it are related to the package management and the wiki, they are still unbeatable for me.

![I use Arch, btw](https://i.kym-cdn.com/entries/icons/original/000/038/795/tco_-_2021-11-09T131430.682.jpg)

## Window manager

I started to use Gnome as my desktop environment at the start of 2021 when I bought a better laptop (before then, I was using [LXDE](https://www.lxde.org/)). However, since I migrated to Arch Linux, I was thinking that it would be nice to try a tiling window manager. So, during the mid-year vacation, I started to study about some of them to see which one should I choose. At first, I installed [AwesomeWM](https://awesomewm.org/), but I didn't like the layout system, which led me to try the traditional [i3wm](https://i3wm.org/).

I took some days to adapt to it, but after i configured [rofi](https://github.com/davatorium/rofi), [kitty](https://sw.kovidgoyal.net/kitty/) and [polybar](https://polybar.github.io/), my workflow migration went smoothly (just with a lot more memorized shortcuts). In fact, the new workflow is pretty similar to my previous Gnome workflow, since I used an extension to mimic the tiling feature. But with i3wm, everything felt much more responsive and I was able to customize almost everything (much better if compared to Gnome, where I was heavily depended on the extensions).

## Text editor

Another big change I made and one that I will maybe maintain this year is my new main text editor. Previously, I used VSCode for everything (like coding, editing simple text files, writing LaTeX documents, etc.) However, before the change, I had already tried some terminal text editors (like [NeoVim](https://neovim.io/) and [GNU Emacs](https://www.gnu.org/software/emacs/)), but it was not the best experience given that I had to learn a lot of new commands and shortcuts, and all the customizations for the best workflow were vert time consuming.

Fortunately, I found [Helix](https://helix-editor.com/). The developers describe it as a "post-modern text editor", and it's developed entirely in Rust. This text editor can be described as if NeoVim and [Kakoune](https://kakoune.org/) had a child, given that it is a modal editor where you first select, then apply a modification. Helix also has a lot of builtin features, like language server support, tree sitter integration, fuzzy finder, etc.

![Helix editor](https://helix-editor.com/signature-help.gif)

The good part is that the configuration file tends to be very minimal, because it already have sane defaults for a modern text editor. For exemple, this is my current configuration file:

```toml
theme = "ayu"

[editor]
line-number = "relative"
bufferline = "multiple"
auto-format = false

[editor.lsp]
display-inlay-hints = false

[editor.file-picker]
hidden = false

[keys.normal]
esc = ["collapse_selection", "keep_primary_selection"]
"C-f" = ":format"
```

However, as of December 2023, Helix still lacks support for a [plugin system](https://github.com/helix-editor/helix/discussions/3806), so I still use VSCode as a fallback when something does't work well on Helix. However, I will try to configure NeoVim from the scratch in the next year and, if a minimal configuration (without all the bullshit of the pre-configured distributions) suits me, I will consider switch from Helix or use both.

## Conclusion

In short, I don't want to drastically change my workflow this year, because what I have is good enough for my use. But, who knows? I hope to at least test new things and see for myself if I don't need to change anything for something better.
