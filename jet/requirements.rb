# typed: strict
# frozen_string_literal: true

require 'global' unless defined?(T)

require 'active_support'
require 'requirement'

require_relative '../lib/functions'

# This module contains the calls
#
module Jet
  # Cask Requirements module for Applications and it dependant {Cask}s
  # Installs Cask/Formula if not installed and return true after installed 
  # so that cask or formula can continue with installation
  module Requirements
    # Requirements for AppCode
    class AppCode < Requirement
      NAME = name.demodulize
      fatal true
      satisfy(build_env: false) { Functions.satisfy(NAME, false) }
    end

    # Requirements for CLion
    class CLion < Requirement
      NAME = name.demodulize
      fatal true
      satisfy(build_env: false) { Functions.satisfy(NAME, false) }
    end

    # Requirements for DataGrip
    class DataGrip < Requirement
      NAME = name.demodulize
      fatal true
      satisfy(build_env: false) { Functions.satisfy(NAME, false) }
    end

    # Requirements for Docker
    class Docker < Requirement
      NAME = name.demodulize
      fatal true
      satisfy(build_env: false) { Functions.satisfy(NAME, false) }
    end

    # Requirements for Gateway
    class Gateway < Requirement
      NAME = "jetbrains-#{name.demodulize}".freeze
      fatal true
      satisfy(build_env: false) { Functions.satisfy(NAME, false) }
    end

    # Requirements for GoLand
    class GoLand < Requirement
      NAME = name.demodulize
      fatal true
      satisfy(build_env: false) { Functions.satisfy(NAME, false) }
    end

    # Requirements for Font JetBrains Mono Nerd
    class FontJetbrainsMonoNerdFont < Requirement
      NAME = name.demodulize.underscore.to_sym.to_s.gsub('_', '-')
      fatal true
      satisfy(build_env: false) { Functions.satisfy(NAME, false) }
    end

    # Requirements for Idea
    class Idea < Requirement
      NAME = "intellij-#{name.demodulize}".freeze
      fatal true
      satisfy(build_env: false) { Functions.satisfy(NAME, false) }
    end

    # Requirements for iTerm2
    class Iterm2 < Requirement
      NAME = name.demodulize
      fatal true
      satisfy(build_env: false) { Functions.satisfy(NAME, false) }
    end

    # Requirements for PyCharm
    class PyCharm < Requirement
      NAME = name.demodulize
      fatal true
      satisfy(build_env: false) { Functions.satisfy(NAME, false) }
    end

    # Requirements for RubyMine
    class RubyMine < Requirement
      NAME = name.demodulize
      fatal true
      satisfy(build_env: false) { Functions.satisfy(NAME, false) }
    end

    # Requirements for Toolbox
    class Toolbox < Requirement
      NAME = "jetbrains-#{name.demodulize}".freeze
      fatal true
      satisfy(build_env: false) { Functions.satisfy(NAME, false) }
    end

    # Requirements for WebStorm
    class WebStorm < Requirement
      NAME = name.demodulize
      fatal true
      satisfy(build_env: false) { Functions.satisfy(NAME, false) }
    end
  end
end

req = Jet::Requirements::WebStorm.new(cask: Jet::Requirements::WebStorm)

puts req.name
