# typed: false
# frozen_string_literal: true

require 'cli/parser'
require 'formula'

require_relative '../lib/functions'
require_relative '../lib/jetbrains'

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }

  def unlinks_args
    Homebrew::CLI::Parser.new do
      description <<~GRC_DESC
        Patches grc.
      GRC_DESC
    end
  end

  def unlinks
    JetBrains.unlinks 
  end
end

