# typed: false
# frozen_string_literal: true

require_relative '../lib/header'

class EnvFile < Formula
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
  depends_on "direnv"
  depends_on "starship"
  
  if OS.mac?
    depends_on "gh"
    depends_on "parallel"
  end
  
  def verify_download_integrity(_fn)
    false
  end
  
  def install
    bin.install Dir["bin/*"]
    bash_completion.install Dir["etc/bash_completion.d/*"]
    etc.install Dir["rc.d/*"] => "rc.d"
    share.install Dir["share/*"]
  end

  test do
    system "#{HOMEBREW_PREFIX}/bin/#{name}", "--help"
  end
end
