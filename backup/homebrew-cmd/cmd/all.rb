# typed: true
# frozen_string_literal: true

require 'cli/named_args'
require 'cli/parser'
require 'tap'
require 'utils/github'
require_relative 'formulas'
require_relative 'taps'

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def all_args
    Homebrew::CLI::Parser.new do
      description <<~ALL_DESC
        Install or uninstall all user/organization formulas/casks.

        With no option, install all formulas.

        It is an alias of: `brew taps --all`

        ENVIRONMENT:
          GITHUB_REPOSITORY   "<user>`/`<repo>"
          USER                "<user>"
      ALL_DESC

      switch '--force',
             description: 'Force overwriting existing files.'

      switch '--ignore-dependencies',
             description: 'An unsupported Homebrew development flag to skip installing any dependencies of any kind. ' \
                          "If the dependencies are not already present, the formula will have issues. If you're not " \
                          'developing Homebrew, consider adjusting your PATH rather than using this flag.'

      switch '--[no-]quarantine',
             description: 'Disable/enable quarantining of downloads (default: enabled).'

      switch '-r', '-u', '--remove', '--uninstall',
             description: 'Uninstall all.'

      switch '-z', '--zap',
             description: 'Remove all files associated with a cask. May remove files which are shared between applications.'

      named_args %i[tap user], max: 1
    end
  end

  def all
    tap, args = tap_fetch_and_parse_args(all_args)
    if args.uninstall?
      taps_list(tap).each do |t|
        formulas_uninstall(t, args)
      end
      system 'brew autoremove --quiet'
    else
      taps_list(tap).each do |t|
        formulas_install(t, args)
      end
    end
  end
end

