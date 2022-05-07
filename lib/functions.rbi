# typed: strict
# sig/functions.rbs

module Functions
  extend T::Sig

  module_function

  def compgen: () -> void

  def exists?: (ref: String | Pathname) -> bool

  def post_install: () -> void

  def satisfy: (ref: String | Pathname, formula: bool = true) -> bool

  def sha256: (path: String) -> String

  def tap!: (ref: String | Pathname) -> void
end
