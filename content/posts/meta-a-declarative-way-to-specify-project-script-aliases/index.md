---
title: 'Meta: a declarative way to specify project script aliases'
tags:
- Programming
- Scripting
date: 2023-12-20
draft: true
math: true
---

For the most part of the programming projects I am working, I like to specify some aliases for common scripts. Them problem is... I have never been satisfied on how to specify such aliases. On JavaScript projects with Node, it is possible to user the `package.json` scripts property, but this approach is obviously language-specific and cannot be used on other types of projects.

On other languages, I usually make the use of [GNU Make](https://www.gnu.org/software/make/), which can be not ideal for some specific cases, like when it is needed to specify arguments. In fact, [it is possible to pass arguments](https://stackoverflow.com/questions/2826029/passing-additional-variables-from-command-line-to-make), but it is still not the best solution for me, because I don't have the control over which parameters are allowed to be passed.

So I tried to hack my own solution named Meta[^meta].

## Meta

Meta is a simple script. At first, it user the [PyYAML](https://pypi.org/project/PyYAML/) library to load the YAML config file from the current directory into a Python dictionary. After this step, it parses the config dictionary based on the the following structure:

```python
@dataclass
class Arg:
    name: str

@dataclass
class Script:
    command: str
    args: list[Arg]

@dataclass
class Meta:
    scripts: dict[Script]
```

This structure was built this way to allow more features in the future, like specifying default argument values, help messages, project-specific configuration (if necessary), etc.

Finally, the `Meta` instance is used to match the arguments passed to the Meta script (available in Python via the `sys.argv` list) and run the correct command by providing the script command with the correct argument values. This means that the arguments must be passed to the Meta script in the same order as specified in the config file.

The complete implementation can be found [here](https://github.com/juanbelieni/meta/blob/main/meta.py).

## Considerations and further work

I started to write this script just to help me organize the commands of the repository for this new blog I'm starting, so I thought it would be a good topic for the first post.

Futhermore, It was made in Python because I was planning to use the [argparse](https://docs.python.org/3/library/argparse.html) library as a back-end to specify the commands, but I choose to not use it because I wanted to have more control over how it works. Because of this, I still have to develop better the error and help messages part.

In the future, I plan to evaluate if handling the arguments as positional is the best option, because I want a way to specify them through their names.

[^meta]: Not to be confused with the tech company. Meta is not from Meta.
