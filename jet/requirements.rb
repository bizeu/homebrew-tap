# typed: strict
# frozen_string_literal: true

require 'global' unless defined?(T)

require 'active_support/inflector'
require 'requirement'

require_relative '../lib/functions'

# This module contains the Casks dependencies for Jet
#
module Jet
  # Allows Installation of Cask Dependencies on Formulas.
  # Cask Requirements module for Applications and it dependant {Cask}s
  # Installs Cask/Formula if not installed and return true after installed
  # so that cask or formula can continue with installation
  #
  # Examples:
  #
  #   depends_on Jet::Requirements::AppCode
  module Requirements
    # Requirements for AppCode
    class AppCode < Requirement
      fatal true
      satisfy(build_env: false) { Functions.satisfy(name.demodulize, formula: false) }
    end

    # Requirements for CLion
    class CLion < Requirement
      fatal true
      satisfy(build_env: false) { Functions.satisfy(name.demodulize, formula: false) }
    end

    # Requirements for DataGrip
    class DataGrip < Requirement
      fatal true
      satisfy(build_env: false) { Functions.satisfy(name.demodulize, formula: false) }
    end

    # Requirements for Docker
    class Docker < Requirement
      fatal true
      satisfy(build_env: false) { Functions.satisfy(name.demodulize, formula: false) }
    end

    # Requirements for Gateway
    class Gateway < Requirement
      fatal true
      satisfy(build_env: false) { Functions.satisfy("jetbrains-#{name.demodulize}", formula: false) }
    end

    # Requirements for GoLand
    class GoLand < Requirement
      fatal true
      satisfy(build_env: false) { Functions.satisfy(name.demodulize, formula: false) }
    end

    # Requirements for Font JetBrains Mono Nerd
    class FontJetbrainsMonoNerdFont < Requirement
      fatal true
      satisfy(build_env: false) { Functions.satisfy(name.demodulize.underscore.dasherize, formula: false) }
    end

    # Requirements for Idea
    class Idea < Requirement
      fatal true
      satisfy(build_env: false) { Functions.satisfy("jetbrains-#{name.demodulize}", formula: false) }
    end

    # Requirements for iTerm2
    class Iterm2 < Requirement
      fatal true
      satisfy(build_env: false) { Functions.satisfy(name.demodulize, formula: false) }
    end

    # Requirements for PyCharm
    class PyCharm < Requirement
      fatal true
      satisfy(build_env: false) { Functions.satisfy(name.demodulize, formula: false) }
    end

    # Requirements for RubyMine
    class RubyMine < Requirement
      fatal true
      satisfy(build_env: false) { Functions.satisfy(name.demodulize, formula: false) }
    end

    # Requirements for Toolbox
    class Toolbox < Requirement
      fatal true
      satisfy(build_env: false) { Functions.satisfy("jetbrains-#{name.demodulize}", formula: false) }
    end

    # Requirements for WebStorm
    class WebStorm < Requirement
      fatal true
      satisfy(build_env: false) { Functions.satisfy(name.demodulize, formula: false) }
    end
  end
end
