# typed: strict
# sig/functions.rbs

module Functions
  module_function
  def compgen: (full_name: String?, version: String?) -> nil
  def exists?: (ref: String | Pathname) -> bool
  def post_format: (full_name: String?, version: String?) -> nil
  def satisfy: (ref: String | Pathname, formula: bool = true) -> bool
  def sha256: (path: String) -> String
  def tap!: (ref: String | Pathname) -> nil
end
