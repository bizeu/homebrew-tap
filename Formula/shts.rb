# typed: false
# frozen_string_literal: true
require "#{ENV["HOMEBREW_LIBRARY"]}/Taps/j5pu/homebrew-cmd/cmd/taps"
require_relative '../../../j5pu/homebrew-cmd/cmd/taps'
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
  depends_on "parallel" if OS.mac?
  
  link_overwrite "bin/bats"
  
  def verify_download_integrity(_fn)
    false
  end
  
  def install
    bin.install Dir["bin/*"]
    bash_completion.install Dir["etc/bash_completion.d/*"]
  end

  test do
    system "#{HOMEBREW_PREFIX}/bin/#{name}", "--help"
  end
end
