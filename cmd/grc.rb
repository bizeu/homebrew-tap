# typed: false
# frozen_string_literal: true

require 'cli/parser'
require 'formula'

require_relative '../lib/functions'

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }

  def grc_args
    Homebrew::CLI::Parser.new do
      description <<~GRC_DESC
        Patches grc.
      GRC_DESC
    end
  end

  def grc
    return unless Functions::exist?(__method__.to_s)
    before = "on_blue"
    file="#{Formula[__method__.to_s].pkgshare}/conf.dockerps"
    if File.binread(file).include? before
      Utils::Inreplace.inreplace(file, before, "blue", false) 
      ohai "Patched: #{Formatter.success(__method__.to_s)}"
    end
  end
end

