# typed: strict
# frozen_string_literal: true

# Startup file for homebrew-tap, should be the first one to loaded

# curl, cargar la de pretty print y usar despues de instalar /usr/local/Homebrew/Library/Taps/j5pu/homebrew-tap/.brew/Library/Homebrew/standalone/load_path.rb
puts RUBY_VERSION
# TODO: curl y el cargar los modulos si no hay T.
#  y con eso creo que todo resuleto

unless defined?(T)
  require 'vendor/bundle/bundler/setup'
  require 'sorbet-runtime-stub' # require "standalone/sorbet" funcionan#
end
require 'cask/config'

require "bundler"

