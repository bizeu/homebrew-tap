# typed: strict
# sig/jetbrains.rbs

class JetBrains
  DEFAULT: Symbol
  NAMES: Hash
  API: URI
  APPDIR: Pathname
  JETBRAINS: Pathname
  REPO: URI
  SCRATCH: Pathname
  @@data: Hash
  @@repo: bool?
  attr_reader name: Symbol
  def initialize: (name: Symbol = ...) -> nil
  def data: () -> Hash
  def self.data: () -> Hash
  def enable?: () -> bool
  def self.enabled: () -> Array[Symbol]
  def self.globals: () -> Hash[String, String]
  def link: () -> nil
  def self.links: () -> nil
  def self.mkdirs: () -> nil
  def self.repo: () -> nil
  def self.requirements: (cls: Formula) -> nil
  def script: () -> nil
  def self.scripts: () -> nil
  def hash: () -> Hash
  def to_s: () -> String
end
