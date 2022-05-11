#!/bin/bash
set -eu
cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

eval "$("${PWD}/.rbenv/bin/rbenv" init -)"

rbenv exec gem install bundler
rbenv rehash
bundle update --bundler
bundle install
rbenv rehash
