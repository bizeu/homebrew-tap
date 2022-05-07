# typed: false
# frozen_string_literal: true

require 'cli/parser'

require_relative '../lib/functions'

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }

  def satisfy_args
    Homebrew::CLI::Parser.new do
      description <<~SATISFY_DESC
        Install Cask or Formula if not Installed (and its container tap if not installed).

      SATISFY_DESC

      switch '-f', '--formula', '--formulae',
             description: 'Treat named argument as formulae.'

      named_args [:cask, :formula], number: 1
    end
  end

  def satisfy
    args = satisfy_args.parse
    Functions::satisfy(args.named.first, args.formula?)
  end
end
