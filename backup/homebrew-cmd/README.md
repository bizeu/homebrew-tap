# homebrew-cmd

![main](https://github.com/j5pu/homebrew-taps/actions/workflows/main.yaml/badge.svg)

Homebrew tap external command.

## Install

```bash
brew tap j5pu/cmd
```

## Development

```shell
brew install rbenv

export PATH="/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/3.1.0/bin:$PATH"
rbenv install 3.1.0
eval "$(rbenv init -)"
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-doctor | bash
ruby --version
brew install brew-gem
bundle install
bundle update --bundler

bundle exec srb init
bundle exec srb tc
brew install-bundler-gems

# `../../../usr/local/Homebrew/Library/Homebrew/vendor/bundle`
```

![ProjectStructure.png](./.idea/Project%20Structure.png)
