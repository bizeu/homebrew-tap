# typed: ignore
# frozen_string_literal: true

require "requirement"

require_relative "../lib/functions"
require_relative "../lib/header"
require_relative "../lib/jetbrains"


class Idea < Requirement
  fatal true
  satisfy(build_env: false) { Functions::satisfy("intellij-#{name}", false) }
end

class PyCharm < Requirement
  fatal true
  satisfy(build_env: false) { Functions::satisfy(name, false) }
end

class RubyMine < Requirement
  fatal true
  satisfy(build_env: false) { Functions::satisfy(name, false) }
end

class Ide < Formula
  Header.run(__FILE__, self)

  depends_on "gh"
  depends_on "grc"
  depends_on "j5pu/tap/bats"
  depends_on "j5pu/tap/binsh"
  depends_on JetBrains.depends_on(self)
  
  def verify_download_integrity(_fn)
    false
  end
  
  def install
    bash_completion.install Dir["etc/bash_completion.d/*"]
    bin.install Dir["bin/*"]
    share.install Dir["share/*"]
  end
  
  def post_install
    Functions::compgen(full_name, version)
  end

  test do
    system "#{HOMEBREW_PREFIX}/bin/#{name}", "--help"
  end
end
