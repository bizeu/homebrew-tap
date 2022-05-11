# typed: ignore
# frozen_string_literal: true

require 'utils/formatter'

require_relative '../cmd/compgen'
require_relative '../cmd/grc'
require_relative '../lib/functions'
require_relative '../lib/header'

# Binsh Formula class
#
class Binsh < Formula
  Header.run(__FILE__, self)

  depends_on 'asciidoctor' => :recommended
  depends_on 'most' => :recommended
  depends_on 'cloudflare-wrangler' => :recommended
  depends_on 'curl' # for :homebrew_curl
  depends_on 'direnv'
  depends_on 'gh'
  depends_on 'grc'
  depends_on 'ipython'
  depends_on 'jq'
  depends_on 'pip-completion'
  depends_on 'pyenv'
  depends_on 'python@3.10'
  depends_on 'starship'
  depends_on 'vercel-cli' => :recommended
  depends_on 'wget'
  depends_on 'whalebrew'  # whalebrew completion bash
  depends_on 'dopplerhq/cli/doppler' => :recommended
  depends_on 'j5pu/tap/bats'

  if OS.mac?
    depends_on 'brew-cask-completion' => :recommended
    depends_on 'coreutils'
    depends_on 'launchctl-completion' => :recommended
    depends_on 'openssh'
  else
    depends_on 'man-db' => :recommended
  end

  def verify_download_integrity(_fn)
    false
  end

  def install
    bash_completion.install Dir['etc/bash_completion.d/*']
    bin.install Dir['bin/*']
    share.install Dir['share/*']
  end

  def post_install
    Functions.compgen(full_name, version)

    tool = 'grc'
    if Functions.exists?(tool)
      dest = Pathname(etc / "profile.d/#{tool}.sh")
      ohai dest.make_relative_symlink(etc / "#{tool}.sh") unless dest.symlink?
      ohai "Postinstalled: #{Formatter.success(tool)}"
    end

    tool = 'whalebrew'
    if Functions.exists?(tool)
      `#{tool} completion bash >> #{etc}/bash_completion.d/#{tool}`
    else
      system "rm -f #{etc}/bash_completion.d/#{tool}"
    end
    ohai "Postinstalled: #{Formatter.success(tool)}"
  end

  if Functions.exists?('grc') && (File.binread("#{Formula['grc'].pkgshare}/conf.dockerps").include? 'on_blue')
    def caveats
      <<~FUNCTIONS
        "run `brew grc` to patch grc"
      FUNCTIONS
    end
  end

  test do
    system "#{HOMEBREW_PREFIX}/bin/#{name}", '--help'
  end
end
