# typed: true
# frozen_string_literal: true

require "digest"

module Functions
  extend T::Sig
  
  module_function
  # Append Path to Api Repos URL for Repository Name
  # @param key [String] @_repos key
  # @param subroutes [String] subroutes to add to value from @_repos
  sig { returns(URI) }
  def _append(key, *subroutes)
    URI.parse([_repo[key], *subroutes].join("/"))
  end
  
  sig { returns(T.nilable(Hash)) }
  def api_auth_repos_repo
    nil
  end
  
  # File SHA256 Hexdigest.
  #
  # @param [String] path the path to the file
  # @return [String] file sha256 hexdigest
  sig {params(path: String).returns(String) }
  def sha256_file(path)
    Digest::SHA256.file(path).hexdigest
  end  
end
