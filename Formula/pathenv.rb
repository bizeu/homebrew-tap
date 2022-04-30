# typed: false
# frozen_string_literal: true

require_relative '../lib/autoformula'

class PathEnv < AutoFormula
  depends_on "bash"
  depends_on "bash-completion@2"
  depends_on "direnv"
  depends_on "git"

  def install
    bin.install Dir["bin/*"]
    bash_completion.install Dir["etc/bash_completion.d/*"]
    etc.install Dir["rc.d/*"] => "rc.d"
    share.install Dir["share/*"]
  end
  
  def post_install
    ohai "post install: #{name}"
    super(post_install)
  end
  
  test do
    system "#{HOMEBREW_PREFIX}/bin/#{name}", "--help"
  end
end
