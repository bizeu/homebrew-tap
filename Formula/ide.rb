# typed: ignore
# frozen_string_literal: true

require "requirement"

require_relative "../lib/functions"
require_relative '../lib/header'


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
  @@header = Header.new(__FILE__)
  
  desc @@header.desc
  homepage @@header.homepage
  url @@header.url, **@@header.using
  sha256 @@header.sha256
  license @@header.license
  version @@header.version
  head @@header.head, branch: @@header.branch 

  depends_on "gh"
  depends_on "grc"
  depends_on "j5pu/tap/bats"
  depends_on "j5pu/tap/binsh"
  
  if OS.mac?
    depends_on Idea
    depends_on PyCharm
    depends_on RubyMine
  end

  def verify_download_integrity(_fn)
    false
  end
  
  def install
    bash_completion.install Dir["etc/bash_completion.d/*"]
    bin.install Dir["bin/*"]
    share.install Dir["share/*"]
  end
  
  def post_install
    Functions::post_install(full_name, version)
  end

  test do
    system "#{HOMEBREW_PREFIX}/bin/#{name}", "--help"
  end
end
