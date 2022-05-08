# typed: strict
# sig/header.rbs

require "tap"
require "uri"
require_relative "repo"

class Header
  extend T::Sig

  attr_reader file: String
  attr_reader full_name: String
  attr_reader name: String
  attr_reader repo: Repo
  attr_reader tap: Tap
  attr_reader user: String

  #sig { params(file: T.nilable(String)).returns(void) }
  def initialize: (file: T.nilable(String) = ...) -> void

  def run: (file: T.nilable(String) = ...) -> void

  def branch: () -> String
  def cask?: () -> bool
  def desc: () -> String
  def formula?: () -> bool
  def head: () -> String
  def homepage: () -> String
  def license: () -> String
  def sha256: () -> String
  def strategy: () -> :curl | :homebrew_curl
  def url: () -> String
  def version: () -> String
end
