# typed: false
# frozen_string_literal: true

require_relative '../cmd/compgen'
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
    include.install Dir["rc.d/*"] => "rc.d"
    share.install Dir["share/*"]
  end
  
  # TODO: no se si es "compgen" o "compgen.compgen", o hacer "include compgen" en las clase
  def post_install
    ohai "post install: #{name}"
    compgen
    super(post_install)
  end
  
  test do
    system "#{HOMEBREW_PREFIX}/bin/#{name}", "--help"
  end
end
