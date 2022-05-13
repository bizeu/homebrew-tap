.PHONY: brew-install bundle tests

SHELL := $(shell bash -c 'command -v bash')
#BASH_ENV := .env.sh
#export BASH_ENV

brew:
	@rm -rf .brew;mkdir -p .brew && curl -fsSL https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C .brew
	@.brew/bin/brew update --force --quiet

brew2: brew
	@# Installs: vendor/ruby/2.6.0 (Homebrew/Gemfile including sorbet)
	@# Installs: vendor/portable-ruby/2.6.8 (the same as 'brew vendor-install')
	@HOMEBREW_SORBET_RUNTIME=1 HOMEBREW_FORCE_VENDOR_RUBY=1 .brew/bin/brew vendor-gems  # opt & lib empty
	@# Installs: only the required at the bottom of (Homebrew/Gemfile including sorbet)
	@.brew/bin/brew install brew-gem

brew3: brew
	@# Installs: vendor/ruby/3.1.0 (Homebrew/Gemfile including sorbet), there is no 3.1 portable available
	@# Installs: vendor/portable-ruby/3.1.0 (the same as 'brew vendor-install')
	@.brew/bin/brew install ruby  # HOMEBREW_REQUIRED_RUBY_VERSION does not force to use a different version
	@PATH=$$PWD/.brew/opt/ruby/bin:$$PATH HOMEBREW_SORBET_RUNTIME=1 HOMEBREW_FORCE_VENDOR_RUBY=1 .brew/bin/brew vendor-gems
	@# Installs: only the required at the bottom of (Homebrew/Gemfile including sorbet)
	@#HOMEBREW_REQUIRED_RUBY_VERSION=3.1.0 .brew/bin/brew install brew-gem

bundle:
	@eval "$$(.rbenv/bin/rbenv init -)"; \
		@rbenv exec gem install bundler; \
		@rbenv rehash; \
		@bundle update --bundler; \
		@bundle install; \
		@rbenv rehash

rbenv:
	@rbenv install 3.1.0

env:
	# Installs: vendor/2.6.0: install all in Homebrew/Gemfile including sorbet vendor/ruby
	@HOMEBREW_SORBET_RUNTIME=1 HOMEBREW_FORCE_VENDOR_RUBY=1 brew vendor-gems
	@HOMEBREW_SORBET_RUNTIME=1 brew vendor-gems  # 2.6.0: install all in Homebrew/Gemfile including sorbet vendor/ruby
	@HOMEBREW_SORBET_RUNTIME=1 brew install brew-gem  # Does not do anything
	@# brew install ruby
#	@brew install brew-gem
#	@brew vendor-gems
#	@brew vendor-install
#	@bundle update --bundler
#	@bundle install

tests:
	@bundle exec rspec

tests-verbose:
	@bundle exec rspec --format documentation
