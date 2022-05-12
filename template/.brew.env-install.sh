#!/bin/bash
# shellcheck shell=bash

unset BASH_ENV
cd "$(dirname "${BASH_SOURCE[0]}")" || return 1

export HOMEBREW_REQUIRED_RUBY_VERSION=3.1.0

eval "$(brew shellenv)"

brew list ruby &>/dev/null || brew install --quiet ruby

HOMEBREW_SYSTEM="$(uname -s)"; export HOMEBREW_SYSTEM
if test "${HOMEBREW_SYSTEM}" = "Darwin"; then
  HOMEBREW_MACOS_VERSION="$(sw_vers -productVersion)"; export HOMEBREW_MACOS_VERSION
fi
export HOMEBREW_LIBRARY="${HOMEBREW_REPOSITORY}/Library"
export HOMEBREW_CACHE="${PWD}/.cache"
export HOMEBREW_LOGS="${PWD}/.logs"
export HOMEBREW_TEMP="${PWD}/.tmp"
export HOMEBREW_BREW_FILE="${HOMEBREW_REPOSITORY}/bin/brew"
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_SORBET_RUNTIME=1  # avoid brew to force raise cannot load sorbet-runtime-stub
export RBENV_VERSION="${HOMEBREW_REQUIRED_RUBY_VERSION}"
export RBENV_ROOT=${PWD}/.rbenv

export HOMEBREW_MODULE="${HOMEBREW_LIBRARY}/Homebrew"
export HOMEBREW_GEMFILE="${HOMEBREW_MODULE}/Gemfile"

vendor="${PWD}/.bundle/ruby/${HOMEBREW_REQUIRED_RUBY_VERSION}"
export GEM_HOME="${vendor}/gems"
export GEM_PATH="${GEM_HOME}"
export RUBYLIB="${PWD}:${HOMEBREW_MODULE}:${GEM_HOME}"

PATH="${PWD}/bin:${GEM_HOME}/bin:${vendor}/bin:${PATH}"

