# typed: false
# frozen_string_literal: true

class Shts < Formula
  formula=name.demodulize
  github="https://github.com/bizeu/#{formula}"
  sha256 "e46ab1db43e9ee97028ce3b6347d839727c3ac7d0ed61c031afae84126c6871d"
  desc ""
  homepage github.to_s
  license "MIT"
  head github.to_s, { branch: "main" }
  
  depends_on "bash"
  depends_on "bash-completion@2"
  depends_on "bats-core" => :keg_only
  depends_on "bats-core/bats-core/bats-assert" => :keg_only
  depends_on "bats-core/bats-core/bats-file" => :keg_only
  depends_on "bats-core/bats-core/bats-support" => :keg_only
  depends_on "parallel" if OS.mac?

  def install
    bin.install mierda.sh
    bin.install Dir["bin/*"]
    bash_completion.install Dir["etc/bash_completion.d/*"]
  end

  test do
    system "#{HOMEBREW_PREFIX}/bin/#{name}", "--help"
  end
end
