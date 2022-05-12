# typed: true
# frozen_string_literal: true

require 'active_support/inflector'
require 'awesome_print'

require 'global' unless defined?(T)
require 'requirement'

require_relative 'script'

module Jet
  # Base Application class for JetBrains
  class Application

    # Application Code
    # JetBrains API application short code
    # @return [String]
    attr_reader :code

    # Application Contents Path
    # start directory with contents of the application directory
    # @return [Pathname] the version of the application
    attr_reader :contents

    # Application Enabled
    # true if the application should be installed and active on the system
    # @return [String] the version of the application
    attr_reader :enable

    # Application Full Name
    # i.e. "IntelliJ Idea" for macOS
    # @return [String]
    attr_reader :full_name

    # Application Name Lowercase
    # @return [String]
    attr_reader :lower

    # Application Name
    # it's the default name for the application directory (.app will be added) and for other directories.
    # @return [Symbol]
    attr_reader :name

    # Application Path
    # it's the full path of the installation directory for the application
    # @return [Pathname]
    attr_reader :path

    # Application Prefix
    # it's the prefix for the application installation directory
    # i.e. "IntelliJ" for macOS "IntelliJ IDEA.app"
    # @return [String]
    attr_reader :prefix

    # Application Script
    # {Script} instance
    # @return [Script]
    attr_reader :script

    # -Xms memory size value for vmoptions
    # @return [String] the version of the application
    attr_reader :xms

    # -Xmx memory size value for vmoptions
    # @return [String] the version of the application
    attr_reader :xmx

    # Creates a Hash with Instances of the Application class
    # @param [Hash[Symbol, [bool, Integer, String]]] kwargs the options to create the applications
    # @return [Hash[Symbol, Application]] application instances
    def self.applications(**kwargs)
      @applications ||= Hash[kwargs.keys.collect { |name| [name, new(name, data)] }]
    end

    # Creates Base Application Instance
    #
    # @param [Symbol] name application name
    # @param [Hash[Symbol, [bool, Integer, String]]] data application data
    def initialize(name, data)
      @name = name
      @enable = OS.linux? && name == :AppCode ? false : data[:enable]
      @code = data[:code]
      @lower = name.to_s.downcase
      @prefix = OS.mac? ? data.fetch(:prefix, '') : ''
      @full_name = @prefix.nil? ? '' : "#{@prefix} " + @name.to_s
      @path = Config::APPDIR / "#{@full_name}.app"
      @contents = @path / (OS.mac? ? 'Contents' : '.')
      @script = Script.new(name, @contents, @lower)

      @xms = "-Xms#{data.fetch(:xms, Config::XMS)}m"
      @xmx = "-Xmx#{data.fetch(:xms, Config::XMX)}m"
    end

    # {Cask} name for macOS
    # @return [String] name of the cask
    def cask
      @cask ||= "#{@full_name}#{@name}".underscore.dasherize
    end

    # Application Installed?
    # main executable script in target directory if linux or cask installed? status if mac
    # @return [bool] true if the application is installed
    def installed?

    end
    
    # Hash of application attributes
    # @return [Hash] the attributes of the application
    def to_hash
      {
        code:,
        enable:,
        full_name:,
        name:,
        path:,
        prefix:,
        xms:,
        xmx:
      }
    end

    # print the application attributes
    # @return [nil] the attributes of the application
    def print
      ap to_hash
    end

    def to_s
      name.to_s
    end
  end
end
