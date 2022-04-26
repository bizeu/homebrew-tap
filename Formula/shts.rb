# typed: false
# frozen_string_literal: true

require_relative '../lib/header'

class Shts < Formula
  header = Header.new(__FILE__)

  desc header.desc
  homepage header.homepage
  url header.url
  sha256 header.sha256
  license header.license
  version header.version
  head header.head, branch: header.branch 
  
  depends_on "bash"
  depends_on "bash-completion@2"
  depends_on "bats-core"
  depends_on "bats-core/bats-core/bats-assert"
  depends_on "bats-core/bats-core/bats-file"
  depends_on "bats-core/bats-core/bats-support"
  
  if OS.mac?
    depends_on "gh"
    depends_on "parallel"
  end
  
  link_overwrite "bin/bats"
  
  def verify_download_integrity(_fn)
    false
  end
  
  def install
    bin.install Dir["bin/*"]
    bash_completion.install Dir["etc/bash_completion.d/*"]
  end

  # TODO: aquí lo dejo
  def post_install
    oh1 "credential-gh"
  end
  
  test do
    system "#{HOMEBREW_PREFIX}/bin/#{name}", "--help"
  end
end
