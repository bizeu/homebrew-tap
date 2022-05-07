# typed: false
# frozen_string_literal: true

require 'cli/parser'

require_relative "../lib/functions"

module Homebrew
  extend T::Sig

  module_function

  COMPLETIONS_BASH ||= (Completions::COMPLETIONS_DIR/"bash/brew").freeze
  COMPLETIONS_ZSH ||= (Completions::COMPLETIONS_DIR/"zsh/_brew").freeze
  
  sig { returns(CLI::Parser) }

  def compgen_args
    Homebrew::CLI::Parser.new do
      description <<~COMPGEN_DESC
        Generate completions file (bash, zsh), updates cached brew subcommands and link taps completions
        
          #{Functions::COMPLETIONS_BASH}
          #{Functions::COMPLETIONS_ZSH}
      COMPGEN_DESC
    end
  end

  def compgen
    Functions::compgen
  end
end
