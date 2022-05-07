# typed: false
# frozen_string_literal: true

require "formulary"
require "cli/parser"

class Symbol
  def f(*args)
    Formulary.factory(to_s, *args)
  end
end

class String
  def f(*args)
    Formulary.factory(self, *args)
  end
end

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def pry_args
    Homebrew::CLI::Parser.new do
      description <<~EOS
        Enter the interactive Homebrew Ruby shell with pry and adds homebrew-tap to LOAD_PATH.
      EOS
    end
  end

  def pry
    Homebrew.install_gem_setup_path! "pry"

    require "pry"
    Pry.config.prompt_name = "tap"

    require "formula"
    require "keg"
    require "cask"
    
    Dir.chdir(`git -C #{Pathname.new(__FILE__).parent} rev-parse --show-toplevel`.chomp)
    $LOAD_PATH.unshift(Pathname.pwd) unless $LOAD_PATH.include?(Pathname.pwd)
    
    Dir["lib/*.rb"].each do |file|
      require Pathname(file).sub_ext("")
    end
    
    Pry.config.history_file = Pathname.pwd + ".pry_history"
    Pry.config.pager = false
    
    Pry.start
  end
end
