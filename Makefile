.PHONY: audit brew publish tests

SHELL := $(shell bash -c 'command -v bash')
msg := feat: first
export msg
formulas := $(shell find Formula -name '*.rb' -type f -exec basename {} .rb \;)

audit:
	@for formula in $(formulas); do \
brew audit --new --git --formula Formula/$${formula}.rb || true; \
done

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
