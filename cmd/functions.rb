# typed: false
# frozen_string_literal: true

require 'cli/parser'
require_relative '../cmd/compgen'
require_relative '../lib/functions'

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }

  def functions_args
    Homebrew::CLI::Parser.new do
      description <<~UTILS_DESC
        Call lib functions.
        
        brew functions github_token
        
      UTILS_DESC
    end
  end

  def functions
    puts Homebrew.public_send(*functions_args.parse.named)
#     file = args.no_named? ? Tap.from_path(__FILE__).formula_files[0] : Formulary.resolve(args.named.first).path
#     puts github_token
  end
end

