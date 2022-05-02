# typed: false
# frozen_string_literal: true

require_relative '../cmd/compgen'
require_relative '../lib/header'

class Shbin < Formula
  header = Header.new()

  desc header.desc
  homepage header.homepage
  url header.url
  sha256 header.sha256
  license header.license
  version header.version
  head header.head, branch: header.branch 

  depends_on "asciidoctor"
  depends_on "bash"
  depends_on "bash-completion@2"
  depends_on "bats-core"
  depends_on "gh"
  depends_on "git"
  depends_on "direnv"
  depends_on "bats-core/bats-core/bats-assert"
  depends_on "bats-core/bats-core/bats-file"
  depends_on "bats-core/bats-core/bats-support"
  
  if OS.mac?
    depends_on "coreutils"
    depends_on "parallel"
  end

  link_overwrite "bin/bats"
  
  def verify_download_integrity(_fn)
    false
  end
  
  def install
    bin.install Dir["bin/*"]
    etc.install Dir["etc/*"]
    share.install Dir["share/*"]
  end
  
  def post_install
    ohai "Postinstalling #{Formatter.identifier(full_name)} #{version}"
    begin
      compgen
    rescue
      nil
    end
    
    begin
      autoremove
    rescue
      nil
    end
  end
  
  test do
    system "#{HOMEBREW_PREFIX}/bin/#{name}", "--help"
  end
end
