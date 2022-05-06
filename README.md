# homebrew-tap

[![Build Status](https://github.com/bizeu/homebrew-tap/workflows/main/badge.svg)](https://github.com/bizeu/homebrew-tap/actions/workflows/main.yaml)

Homebrew tap for development.

## Formulas
<!-- project_table_start -->
| Project                                         | Description    | Install                  |
|-------------------------------------------------|----------------|--------------------------|
| [bats-bash](https://github.com/bizeu/bats.bash) | Bats helpers   | `brew install bats-bash` |
| [release](https://github.com/bizeu/release)     | Release Action | `brew install release`   |
<!-- project_table_end -->

## Console
### irb
```shell
PATH="$(brew --prefix ruby)/bin:${PATH}"; export PATH
RUBYLIB="$(brew taps --path)" irb
```

```ruby
$LOAD_PATH
$:
```

### brew irb
`brew irb` unsets `$RUBYLIB`, therefore "." must be added to the `$LOAD_PATH` after irb is started.
```shell
PATH="$(brew --prefix ruby)/bin:${PATH}"; export PATH
RUBYLIB="$(brew taps --path)" irb --pry
```

```ruby
$:.unshift(".")
require "lib/repo"
r = Repo.new("j5pu", "bats")  # main
r = Repo.new("j5pu", "secrets")  # tag (private)
r = Repo.new("bizeu", "release")  # main (private)
r = Repo.new("j5pu", "bindev")  # tag
r = Repo.new("bizeu", "shts")  # release and tag (private)
require "lib/functions"
Functions::github_token
```

`$LOAD_PATH.unshift(".")` can also be used


## Commands
```shell
brew --env
brew commands
brew postinstall
brew tap-info
brew vendor-install
```

## Commands Development
```shell
brew command header
brew completions link
brew formula python@3.9
brew install-bundler-gems
brew irb
brew irb --pry
brew irb --examples
brew rubocop
brew ruby
brew sh
brew sh --cmd=ls
brew style
brew tap-new
brew test
brew test --HEAD
brew update-python-resources
brew vendor-gems
```
