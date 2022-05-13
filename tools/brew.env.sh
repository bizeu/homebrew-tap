#!/bin/bash
set -eu

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

if ! test -d .brew; then
  mkdir .brew && curl -fsSL https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C .brew
  .brew/bin/brew update --force --quiet
  chmod -R go-w ".brew/share/zsh"
fi

eval "$("${PWD}/.rbenv/bin/rbenv" init -)"

rbenv exec gem install bundler
rbenv rehash
bundle update --bundler
bundle install
rbenv rehash

HOMEBREW_FORCE_VENDOR_RUBY
HOMEBREW_DEVELOPER
