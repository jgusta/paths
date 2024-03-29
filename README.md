# paths.fish

> Reveal the named executable matches in shell paths.

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```shell
fisher install jgusta/paths.fish
```

## Usage

paths.fish identifies the executed file for the given symbol. It will also output other path components, in each of the possible system paths, in order of succession. It lists the source of the path components as a header.

```shell
$ paths brew
fish_function_path
 -  /Users/me/.config/fish/fisher_root/functions/brew.fish 

PATH
 -  /usr/local/bin/brew  /usr/local/Homebrew/bin/brew 

```

Possible values for the source headers are `VIRTUAL_ENV`, `fisher_path`, `fish_function_path`, `fish_user_paths`, `PATH`. It even understands python virtual environments:

```shell
$ paths python
VIRTUAL_ENV
 -  /Users/me/code/venv/myprog-QKlu_Gbg/bin/python  /usr/local/Cellar/python@3.9/3.9.19/Frameworks/Python.framework/Versions/3.9/bin/python3.9 

PATH
 -  /usr/local/bin/python  /Library/Frameworks/Python.framework/Versions/2.7/bin/python2.7 

```

Use `-q` to skip the headers and colors and list markers:

```shell
$ paths -q python
/Users/me/code/venv/reoner-QKlu_Gbg/bin/python
/usr/local/bin/python

```

Use `-s` to output the very first result in plaintext:

```shell
$ paths -s python
/Users/me/code/venv/reoner-QKlu_Gbg/bin/python
```

`-s` can be used like the bash command "which"

```shell
$ eval (paths -s python) -m http.server
Serving HTTP on :: port 8000 (http://[::]:8000/) ...
```
