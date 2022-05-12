# typed: true
# frozen_string_literal: true

require 'active_support/inflector'
require 'awesome_print'

require 'global' unless defined?(T)

require_relative 'config'

module Jet
  # Application Scripts class for JetBrains
  class Script

    # Application Bin Directory
    # @return [Pathname] the version of the application
    attr_reader :bin

    # Application Contents Path
    # start directory with contents of the application directory
    # @return [Pathname] the version of the application
    attr_reader :contents
    
    # Application Name Lowercase
    # @return [String]
    attr_reader :lower

    # Application Main Executable Path
    # it's the full path of the application executable
    # @return [Pathname]
    attr_reader :executable

    # Application Name
    # it's the default name for the application directory (.app will be added) and for other directories.
    # @return [Symbol]
    attr_reader :name

    # Creates Application Script Instance
    #
    # @param [Symbol] name application name
    # @param [Pathname] contents start directory with contents of the application directory
    # @param [String] lower application name lowercase
    def initialize(name, contents, lower)
      @name = name
      @contents = contents
      @lower = lower
      @bin = @contents / 'bin'
      if OS.mac?
        directory = @contents / 'MacOS'
        suffix = ''
      else
        directory = @bin
        suffix = '.sh'
      end
      prefix = name == :Toolbox ? 'jetbrains-' : ''
      @executable = directory / (prefix + @lower + suffix)
    end

    # Hash of application attributes
    # @return [Hash] the attributes of the application
    def to_hash
      {
        bin:,
        contents:,
        lower:,
        executable:,
        executable?: executable?,
        name:
      }
    end

    # Application Main Executable Path Exists?
    # @return [bool] true if exists
    def executable?
      executable.exist?
    end

    # print the application attributes
    # @return [nil] the attributes of the application
    def print
      ap to_hash
    end

    def to_s
      @main.to_s
    end
  end
end

name = :Toolbox
app = name.to_s
full_name = "Jetbrains #{app}"
contents = Jet::Config::APPDIR / "#{full_name}.app" / 'Contents'
script = Jet::Script.new(name, contents, app.downcase)
script.print
