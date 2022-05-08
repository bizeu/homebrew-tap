#!/usr/bin/env ruby

require "cask/config"

class Jetbrains

  extend T::Sig
  
  APPDIR ||= Pathname.new(Cask::Config::DEFAULT_DIRS[:appdir]).freeze
  JETBRAINS ||= Pathname.new("/Users/Shared/#{name.to_s}").freeze

  def initialize(file = nil)
    @file = file
    puts APPDIR
    puts CONFIG
  end
end
