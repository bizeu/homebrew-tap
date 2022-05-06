# typed: ignore
# frozen_string_literal: true

class BatsBash < Formula
  desc "Bats helpers"
  homepage "https://github.com/j5pu/bats.bash"
  url "https://github.com/j5pu/bats.bash/archive/refs/tags/v0.0.16.tar.gz"
  sha256 "e3c0a6a48c58c26d3945e6cb95c3a71e4f5d1c7e617666b21c65219b9318ae52"
  license "MIT"

  depends_on "bash"
  depends_on "bash-completion@2"
  depends_on "bats-core"
  depends_on "bats-core/bats-core/bats-assert"
  depends_on "bats-core/bats-core/bats-file"
  depends_on "bats-core/bats-core/bats-support"
  depends_on "parallel" if OS.mac?

  def install
    bin.install Dir["bin/*"]
    bash_completion.install Dir["etc/bash_completion.d/*"]
  end

  test do
    system "#{HOMEBREW_PREFIX}/bin/#{name}", "--help"
  end
end
