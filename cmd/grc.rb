# typed: false
# frozen_string_literal: true

require 'cli/parser'
require 'formula'
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
    before = "on_blue"
    file="#{Formula["grc"].pkgshare}/conf.dockerps"
    if File.binread(file).include? before
      Utils::Inreplace.inreplace(file, before, "blue", false) 
      ohai "Patched: #{Formatter.success(__method__)}"
    end
  end
end

