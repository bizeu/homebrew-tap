# typed: false
# frozen_string_literal: true

require 'cli/parser'
require 'formulary'
require 'tap'
require 'version'
require_relative '../lib/header'

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }

  ENV['GIT_QUIET'] = '1'

  def header_args
    Homebrew::CLI::Parser.new do
      description <<~HEADER_DESC
        Show header info for formula in Taps.
        
        If not formula name is provided, the first formula (Tap.formula_files[0]) for this command tap is used.
      HEADER_DESC

      named_args [:formula], max: 1
    end
  end

  def header
    args = header_args.parse
    file = args.no_named? ? Tap.from_path(__FILE__).formula_files[0] : Formulary.resolve(args.named.first).path
    puts JSON.pretty_generate(Header.new(file).hash)
  end
end

