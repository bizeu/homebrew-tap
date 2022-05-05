# typed: false
# frozen_string_literal: true

require 'utils/formatter'
require 'utils/inreplace'
require "utils/string_inreplace_extension"
require_relative '../cmd/compgen'
require_relative '../cmd/grc'
require_relative '../lib/header'

class Binsh < Formula
  @@header = Header.new(__FILE__)
  
  desc @@header.desc
  homepage @@header.homepage
  url @@header.url
  sha256 @@header.sha256
  license @@header.license
  version @@header.version
  head @@header.head, branch: @@header.branch 

  depends_on "asciidoctor"
  depends_on "bash"
  depends_on "bash-completion@2"
  depends_on "bats-core"
  depends_on "direnv"
  depends_on "gh"
  depends_on "git"
  depends_on "grc"
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
    
    Homebrew::compgen
    ohai "Postinstalled: #{Formatter.success("compgen")}"

    unless dest.symlink?
      dest = Pathname(etc/"profile.d/grc.sh")
      ohai dest.make_relative_symlink(etc/"grc.sh")
      ohai "Postinstalled: #{Formatter.success("grc")}"
    end
    
    begin
      Homebrew::grc
    rescue
      nil
    end
  end
  
  test do
    begin
      Utils::Inreplace.inreplace("#{Formula["grc"].pkgshare}/conf.dockerps", "on_blue", "blue", false)
    rescue
      nil
    end  
    system "true"
#     system "#{HOMEBREW_PREFIX}/bin/#{name}", "--help"
  end
end
