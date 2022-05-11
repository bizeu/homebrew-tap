.PHONY: ruby gems audit brew publish tests

SHELL := $(shell bash -c 'command -v bash')
BASH_ENV := .env
export BASH_ENV

msg := feat: first
export msg
formulas := $(shell find Formula -name '*.rb' -type f -exec basename {} .rb \;)

ruby:
	@rbenv install 3.1.0

brew.env:
	@brew install brew-gem
	@brew vendor-gems


rbenv.env:
	@echo $$PATH
	@rbenv exec gem install bundler
	@rbenv global 3.1.0
	@eval "$(rbenv init -)"; gem install bundler; rbenv rehash; bundle update --bundler; bundle install; rbenv rehash


audit:
	@for formula in $(formulas); do \
brew audit --new --git --formula Formula/$${formula}.rb || true; \
done

gem-build:
	@gem build homebrew_tap.gemspec
gem-install:
	@gem install homebrew_tap-*.gem

brew:
	@! brew list bats 2>/dev/null || brew uninstall bats
	@brew bundle --file Brewfile --quiet --no-lock | grep -v "^Using"

publish:
	@git add .
	@git commit --quiet -a -m "$${msg:-auto}" || true
	@git push --quiet

tests: audit brew
	@brew tap bizeu/tap
	@for formula in $(formulas); do \
brew test bizeu/tap/$${formula}; \
done
