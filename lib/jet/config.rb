# typed: strict
# frozen_string_literal: true

require 'global' unless defined?(T)
require 'cask/config'

# JetBrains module
module Jet
  # Settings module for Jet Projects
  module Config
    APPDIR ||= Pathname.new(Cask::Config::DEFAULT_DIRS[:appdir]).freeze
    DATA ||= {
      AppCode: { enable: true, code: 'AC', Xms: 256, Xmx: 2500 },
      CLion: { enable: true, code: 'CL', Xms: 256, Xmx: 2000 },
      DataGrip: { enable: true, code: 'DG' },
      Gateway: { enable: true, code: 'GW', prefix: 'JetBrains' },
      GoLand: { enable: true, code: 'GO' },
      Idea: { enable: true, code: 'IIU', prefix: 'IntelliJ', Xms: 256, Xmx: 4096 },
      PyCharm: { enable: true, code: 'PCP', Xms: 256, Xmx: 4096 },
      RubyMine: { enable: true, code: 'RM', Xms: 256, Xmx: 2000 },
      Toolbox: { enable: true, code: 'TBA', prefix: 'JetBrains' },
      WebStorm: { enable: true, code: 'WS', Xms: 256, Xmx: 2000 }
    }.freeze
    SHARED ||= Pathname.new('/Users/Shared').freeze
    SCRIPT ||= (Pathname.new(HOMEBREW_PREFIX) / 'bin').freeze
    XMS ||= 128
    XMX ||= 750
  end
end
