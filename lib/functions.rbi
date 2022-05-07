# typed: strict
# sig/functions.rbs

module Functions
  extend T::Sig

  module_function
#   sig {params(path: String).returns(String) }
  def sha256: (path: String) -> String
end
