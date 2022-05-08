# typed: ignore
# frozen_string_literal: true

require_relative "../lib/functions"
require_relative "../lib/header"

class Bats < Formula
  Header.run(__FILE__, self)

  depends_on "bash"
  depends_on "bash-completion@2"
  depends_on "bats-core"
  depends_on "git"
  depends_on "bats-core/bats-core/bats-assert"
  depends_on "bats-core/bats-core/bats-file"
  depends_on "bats-core/bats-core/bats-support"
  
  if OS.mac?
    depends_on "parallel"
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
    Functions::compgen(full_name, version)
  end
  
  test do
    system "#{HOMEBREW_PREFIX}/bin/#{name}", "--help"
  end
end
