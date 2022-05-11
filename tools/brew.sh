#!/bin/bash
set -eu
cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

if ! test -d .brew; then
  mkdir .brew && curl -fsSL https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C .brew
fi
eval "$(.brew/bin/brew shellenv)"
brew update --force --quiet
chmod -R go-w "${HOMEBREW_PREFIX}/share/zsh"

