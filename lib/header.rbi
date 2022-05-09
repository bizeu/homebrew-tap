# typed: strict
# sig/header.rbs

require "tap"
require "uri"
require_relative "repo"

class Header
  attr_reader file: String
  attr_reader full_name: String
  attr_reader name: String
  attr_reader repo: Repo
  attr_reader tap: Tap
  attr_reader user: String
  def initialize: (file: String? = ...) -> nil
  def run: (file: String? = ...) -> nil
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
  def hash: () -> Hash[String, String]
  def to_s: () -> String
end
