# typed: ignore
# frozen_string_literal: true

require "cask/cask_loader"
require "cask/installer"
require "requirement"

require_relative "../cmd/compgen"
require_relative "../lib/functions"
require_relative "../lib/header"


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

class Bats < Formula
  @@header = Header.new(__FILE__)

  desc @@header.desc
  homepage @@header.homepage
  url @@header.url, **@@header.using
  sha256 @@header.sha256
  license @@header.license
  version @@header.version
  head @@header.head, branch: @@header.branch 

  depends_on "bash"
  depends_on "bash-completion@2"
  depends_on "bats-core"
  depends_on "git"
  depends_on "bats-core/bats-core/bats-assert"
  depends_on "bats-core/bats-core/bats-file"
  depends_on "bats-core/bats-core/bats-support"
  
  if OS.mac?
    depends_on "parallel"
    depends_on Idea
    depends_on PyCharm
    depends_on RubyMine
  end

  link_overwrite "bin/bats"

  def verify_download_integrity(_fn)
    false
  end
  
  def install
    bash_completion.install Dir["etc/bash_completion.d/*"]
    bin.install Dir["bin/*"]
    share.install Dir["share/*"]
  end
  
  def post_install
    ohai "Postinstalling #{Formatter.identifier(full_name)} #{version}"
    
    Homebrew::compgen
    ohai "Postinstalled: #{Formatter.success("compgen")}"
  end
  
  test do
    system "#{HOMEBREW_PREFIX}/bin/#{name}", "--help"
  end
end
