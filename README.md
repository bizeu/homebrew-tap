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

## [Header](lib/header.rb)
### Alt 1
```ruby
require_relative "../lib/header"

class Bats < Formula
  Header.run(__FILE__, self)

  depends_on "bash"

  def install
    bin.install Dir["bin/*"]
  end
```

### Alt 2
```ruby
require_relative "../lib/header"

class Bats < Formula
  @@header = Header.new(__FILE__)

  desc @@header.desc
  homepage @@header.homepage
  url @@header.url, **@@header.using
  sha256 @@header.sha256
  license @@header.license
  version @@header.version
  head @@header.head, branch: @@header.branch


  depends_on "bash"

  def install
    bin.install Dir["bin/*"]
  end
```

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
