# typed: ignore
# frozen_string_literal: true

require "active_support"
require "requirement"

require_relative "functions"

module Reqs

  class AppCode < Requirement
    fatal true
    satisfy(build_env: false) { Functions::satisfy(name, false) }
  end

  class CLion < Requirement
    fatal true
    satisfy(build_env: false) { Functions::satisfy(name, false) }
  end
    
  class DataGrip < Requirement
    fatal true
    satisfy(build_env: false) { Functions::satisfy(name, false) }
  end
  
  class Docker < Requirement
    satisfy(build_env: false) { Functions::satisfy(name, false) }
  end
  
  class Gateway < Requirement
    fatal true
    satisfy(build_env: false) { Functions::satisfy("jetbrains-#{name}", false) }
  end
  
  class GoLand < Requirement
    fatal true
    satisfy(build_env: false) { Functions::satisfy(name, false) }
  end

  class FontJetbrainsMonoNerdFont < Requirement
    fatal true
    satisfy(build_env: false) { Functions::satisfy(name.underscore.to_sym.to_s.gsub("_", "-"), false) }
  end

  class Idea < Requirement
    fatal true
    satisfy(build_env: false) { Functions::satisfy("intellij-#{name}", false) }
  end
  
  class Iterm2 < Requirement
    fatal true
    satisfy(build_env: false) { Functions::satisfy(name, false) }
  end
   
  class PyCharm < Requirement
    fatal true
    satisfy(build_env: false) { Functions::satisfy(name, false) }
  end
  
  class RubyMine < Requirement
    fatal true
    satisfy(build_env: false) { Functions::satisfy(name, false) }
  end
  
  class Toolbox < Requirement
    fatal true
    satisfy(build_env: false) { Functions::satisfy("jetbrains-#{name}", false) }
  end
  
  class WebStorm < Requirement
    fatal true
    satisfy(build_env: false) { Functions::satisfy(name, false) }
  end
end
