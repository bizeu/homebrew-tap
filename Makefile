.PHONY: tests

SHELL := $(shell bash -c 'command -v bash')
BASH_ENV := .env.sh
export BASH_ENV


ruby:
	@rbenv install 3.1.0

env:
	@brew install ruby
	@brew install brew-gem
	@brew vendor-gems
	@brew vendor-install
	@bundle update --bundler
	@bundle install

tests:
	@bundle exec rspec

tests-verbose:
	@bundle exec rspec --format documentation
