.PHONY: tests

SHELL := $(shell bash -c 'command -v bash')
BASH_ENV := .env.sh
export BASH_ENV

tests:
	@bundle exec rspec

tests-verbose:
	@bundle exec rspec --format documentation
