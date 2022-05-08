# typed: ignore
# frozen_string_literal: true

require_relative "../lib/header"

class Secrets < Formula
  Header.run(__FILE__, self)

  depends_on "curl" # for :homebrew_curl
  
  def verify_download_integrity(_fn)
    false
  end
  
  def install
    bin.install Dir["bin/*"]
    etc.install Dir["etc/*"]
  end
  
  test do
    system '. #{etc}/profile.d/#{name}.sh && [ "${GH_TOKEN-}" ]'
  end
end
