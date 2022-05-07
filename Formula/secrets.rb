# typed: ignore
# frozen_string_literal: true

require_relative "../lib/header"

class Secrets < Formula
  @@header = Header.new(__FILE__)

  desc @@header.desc
  homepage @@header.homepage
  url @@header.url, **@@header.using
  sha256 @@header.sha256
  license @@header.license
  version @@header.version
  head @@header.head, branch: @@header.branch 

  depends_on "curl" # for :homebrew_curl
  
  def verify_download_integrity(_fn)
    false
  end
  
  def install
    etc.install Dir["etc/*"]
    bin.install Dir["bin/*"]
  end
  
  test do
    system ". #{etc}/profile.d/#{name}.sh && [ "${GH_TOKEN-}" ]"
  end
end
