# typed: strict
# sig/functions.rbs

module Functions
  extend T::Sig

  module_function

  def satisfy: (ref: String | Pathname, cask: bool = true) -> bool

  def sha256: (path: String) -> String
end
