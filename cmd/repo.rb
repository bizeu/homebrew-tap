# typed: false
# frozen_string_literal: true

require 'cli/parser'
require 'formulary'
require 'tap'

require_relative '../lib/repo'

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }

  def repo_args
    Homebrew::CLI::Parser.new do
      description <<~REPO_DESC
        Show repo info for owner and repo name.
        
          `brew repo john tools`
        
      REPO_DESC
      
      named_args [:owner, :name], number: 2
    end
  end

  def repo
    puts JSON.pretty_generate(Repo.new(*repo_args.parse.named).hash)
  end
end

