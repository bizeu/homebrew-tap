# typed: ignore
# frozen_string_literal: true

require_relative "../lib/functions"
require_relative "../lib/header"
require_relative "../lib/jetbrains"
require_relative "../lib/reqs"

class Jet < Formula
  Header.run(__FILE__, self)

  depends_on "bash"
  depends_on "bash-completion@2"
  depends_on "bats-core"
  depends_on "git"
  depends_on "bats-core/bats-core/bats-assert"
  depends_on "bats-core/bats-core/bats-file"
  depends_on "bats-core/bats-core/bats-support"
  JetBrains.requirements(self)
  
  if OS.mac?
    depends_on "parallel"
  end

  link_overwrite "bin/bats"

  def verify_download_integrity(_fn)
    false
  end
  
  service do
#     run [opt_bin/"#{JetBrains::GLOBALS}-service"]
    run [opt_bin/"jet-service"]
    launch_only_once true
  end
  
  def install
    bin.install Dir["bin/*"]
  end
  
  def post_install
    JetBrains.uninstalls
  end
  
  test do
    system "#{HOMEBREW_PREFIX}/bin/#{name}", "--help"
  end
end
