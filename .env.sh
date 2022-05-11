#!/bin/bash
# shellcheck shell=bash

unset BASH_ENV
cd "$(dirname "${BASH_SOURCE[0]}")" || return 1

export HOMEBREW_REQUIRED_RUBY_VERSION=3.1.0

eval "$(.brew/bin/brew shellenv)"

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
export RBENV_VERSION="${HOMEBREW_REQUIRED_RUBY_VERSION}"
export RBENV_ROOT=${PWD}/.rbenv

export HOMEBREW_MODULE="${HOMEBREW_LIBRARY}/Homebrew"
export HOMEBREW_GEMFILE="${HOMEBREW_MODULE}/Gemfile"

eval "$("${RBENV_ROOT}/bin/rbenv" init -)"

export GEM_HOME="${PWD}/.bundle/ruby/${HOMEBREW_REQUIRED_RUBY_VERSION}"
export GEM_PATH="${GEM_HOME}"
export RUBYLIB="${PWD}:${HOMEBREW_MODULE}:${GEM_HOME}"
#export LOAD_PATH="${RUBYLIB}"

PATH="${PWD}/bin:${RBENV_ROOT}/bin:${GEM_HOME}/bin:${PATH}"

