=begin
This module contains the Cask Requirements Classes.
=end
# require "active_support"
require "requirement"

require_relative "functions"

module Reqs

  class AppCode < Requirement
    NAME = name.demodulize
    fatal true
    satisfy(build_env: false) { Functions::satisfy(NAME, false) }
  end

  class CLion < Requirement
    NAME = name.demodulize
    fatal true
    satisfy(build_env: false) { Functions::satisfy(NAME, false) }
  end
    
  class DataGrip < Requirement
    NAME = name.demodulize
    fatal true
    satisfy(build_env: false) { Functions::satisfy(NAME, false) }
  end
  
  class Docker < Requirement
    NAME = name.demodulize
    fatal true
    satisfy(build_env: false) { Functions::satisfy(NAME, false) }
  end
  
  class Gateway < Requirement
    NAME = "jetbrains-#{name.demodulize}"
    fatal true
    satisfy(build_env: false) { Functions::satisfy(NAME, false) }
  end
  
  class GoLand < Requirement
    NAME = name.demodulize
    fatal true
    satisfy(build_env: false) { Functions::satisfy(NAME, false) }
  end

  class FontJetbrainsMonoNerdFont < Requirement
    NAME = name.demodulize.underscore.to_sym.to_s.gsub("_", "-")
    fatal true
    satisfy(build_env: false) { Functions::satisfy(NAME, false) }
  end

  class Idea < Requirement
    NAME = "intellij-#{name.demodulize}"
    fatal true
    satisfy(build_env: false) { Functions::satisfy(NAME, false) }
  end
  
  class Iterm2 < Requirement
    NAME = name.demodulize
    fatal true
    satisfy(build_env: false) { Functions::satisfy(NAME, false) }
  end
   
  class PyCharm < Requirement
    NAME = name.demodulize
    fatal true
    satisfy(build_env: false) { Functions::satisfy(NAME, false) }
  end
  
  class RubyMine < Requirement
    NAME = name.demodulize
    fatal true
    satisfy(build_env: false) { Functions::satisfy(NAME, false) }
  end
  
  class Toolbox < Requirement
    NAME = "jetbrains-#{name.demodulize}"
    fatal true
    satisfy(build_env: false) { Functions::satisfy(NAME, false) }
  end
  
  class WebStorm < Requirement
    NAME = name.demodulize
    fatal true
    satisfy(build_env: false) { Functions::satisfy(NAME, false) }
  end
end
