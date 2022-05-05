# typed: false
# frozen_string_literal: true

require 'cli/parser'
require "commands"
require "completions"

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
        
          #{COMPLETIONS_BASH}
          #{COMPLETIONS_ZSH}
      COMPGEN_DESC
    end
  end

  def compgen
    Homebrew::Completions.link! unless Homebrew::Completions.link_completions?
    Commands.rebuild_commands_completion_list
    commands = Commands.commands(external: true, aliases: true).sort
    for i in [COMPLETIONS_BASH, COMPLETIONS_ZSH]
      begin
        (i).atomic_write Homebrew::Completions.generate_bash_completion_file(commands)
      rescue
        nil
      end
      ohai "Generated: #{i}" if compgen_args.parse.verbose?
    end
    line = "    #{__method__.to_s}) _brew_#{__method__.to_s} ;;"
    odie "#{COMPLETIONS_BASH}:#{line}" unless COMPLETIONS_BASH.binread.include? line
  end
end
