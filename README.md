# jgusta/paths

> Program file locator plugin for Fish

`paths` is a plugin for [fish](https://fishshell.com), the friendly interactive shell.

Use it to locate a program file or executable fish script in the user's path environment variables. Contrast to `which` which does not identify fish function or autoloaded scripts. 

## Installation

Fish plugins are installed with several plugin managers. The best one is [Fisher](https://github.com/jorgebucaran/fisher).

To install with [Fisher](https://github.com/jorgebucaran/fisher):

```shell
fisher install jgusta/paths
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

Use `-c` to skip the headers and colors and list markers:

```shell
$ paths -c python
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

but remember, autoloaded fish scripts are generally not executable:

```shell
eval (paths -s ls)
fish: Unknown command. '/usr/local/Cellar/fish/3.7.1/share/fish/functions/ls.fish' exists but is not an executable file.
/usr/local/Cellar/fish/3.7.1/share/fish/functions/ls.fish
```
