---
title: 'Taking daily notes in plain text'
date: 2024-03-23
math: true
tags: software
---

Taking notes is the kind of task that should be simple. In fact, you just need a small notebook and a pen for this. However, sometimes all I got with me is my smartphone, so I would like to have some sort of solution that synced all my notes between the devices I use.

For note-taking, I like a lot to use [Obsidian](https://obsidian.md), specially because I can render $\LaTeX$ formulas easily while taking my notes (that comes very in hand, given that I sometimes have to take notes related to my college degree). Also, Obsidian has a nice plugin ecosystem. However, Obsidian is not open-source, and there are open-source alternatives like [Logseq](https://logseq.com) (that tries to solve the problem I am talking about). However, I didn't had a good time testing this app, and the notes are not stored as plain text, so it is useless for what I want (sadly).

Wrapping up, I wanted to have a free solution that would work with plain text notes and sync between devices. Fortunately, I have been using [Syncthing](https://syncthing.net/) for quite a while already. It basically sync all the files in a specific repository over your local network, which is very useful given that I almost always connect my smartphone and my laptop to the same Wi-Fi network.

With these two piece of softwares, the setup is trivial. With Obsidian, I created a vault in my laptop, installing the plugins I would like to use for this task. After this, I add this folder to Syncthing and shared with my smartphone and tablet.

Now, I have a very simple note-taking setup for my daily notes that is fully searchable, portable and customizable :)
