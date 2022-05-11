# typed: strict
# frozen_string_literal: true

# This module contains the calls
#
module Jet
  # Settings for Jet Projects
  extend Pathname

  NAMES ||= {
    AppCode: {
      enable: OS.mac? ? true : false, code: 'AC', requirement: Reqs::AppCode, Xms: 256, Xmx: 2500
    },
    CLion: {
      enable: true, code: 'CL', requirement: Reqs::CLion, Xms: 256, Xmx: 2000
    },
    DataGrip: {
      enable: true, code: 'DG', requirement: Reqs::DataGrip, Xms: 128, Xmx: 750
    },
    Gateway: {
      enable: true, code: 'GW', app: OS.mac? ? 'JetBrains Gateway' : nil,
      requirement: Reqs::Gateway, Xms: 128, Xmx: 750
    },
    GoLand: {
      enable: true, code: 'GO', requirement: Reqs::GoLand, Xms: 128, Xmx: 750
    },
    Idea: {
      enable: true, code: 'IIU', app: OS.mac? ? 'IntelliJ IDEA' : nil,
      requirement: Reqs::Idea, Xms: 256, Xmx: 4096
    },
    PyCharm: {
      enable: true, code: 'PCP', requirement: Reqs::PyCharm, Xms: 256, Xmx: 4096
    },
    RubyMine: {
      enable: true, code: 'RM', requirement: Reqs::RubyMine, Xms: 256, Xmx: 2000
    },
    Toolbox: {
      enable: true, code: 'TBA', app: OS.mac? ? 'JetBrains Toolbox' : nil,
      requirement: Reqs::Toolbox, Xms: 128, Xmx: 750
    },
    WebStorm: {
      enable: true, code: 'WS', requirement: Reqs::WebStorm, Xms: 256, Xmx: 2000
    }
  }.freeze
  
  module Settings
    
  end
end
