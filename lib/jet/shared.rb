# typed: true
# frozen_string_literal: true

require 'active_support/inflector'
require 'awesome_print'
require 'global' unless defined?(T)
require 'requirement'
require_relative 'config'

module Jet
  # Application Settings and Config Repository class for JetBrains
  class Shared
    extend T::Sig

    # Application Prefix
    # it's application directory prefix
    # i.e. "IntelliJ" for macOS "IntelliJ IDEA.app"
    # @return [String] the version of the application
    attr_reader :prefix

    # Creates Base Application Instance
    #
    # @param [Symbol] name application name
    # @param [Hash[Symbol, [bool, Integer, String]]] data application data
    def initialize(name, data)
      @name = name
      @xms = "-Xms#{data.fetch(:xms, Config::XMS)}m"
      @xmx = "-Xmx#{data.fetch(:xms, Config::XMX)}m"
    end
  end
end
