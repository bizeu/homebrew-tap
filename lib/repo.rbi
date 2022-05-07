# typed: strict
# sig/repo.rbs

class Repo
  extend T::Sig

  attr_reader name: String
  attr_reader user: String

  # sig { params(user: String, name: String).returns(void) }
  def initialize: (user: String, name: String) -> void

  # sig { returns(URI) }
  def api: () -> URI

  # sig { params(subroutes: String).returns(URI) }
  def api_repos_url: (*subroutes: String) -> URI

  # sig { returns(String) }
  def branch: () -> String

  # sig { returns(Pathname) }
  def cache: () -> Pathname

  # sig { returns(T.nilable(String)) }
  def credentials: () -> T.nilable(String)

  # sig { returns(String) }
  def desc: () -> String

  # sig { returns(T.any(:curl, :homebrew_curl)) }
  def downloader: () -> CurlDownloadStrategy | HomebrewCurlDownloadStrategy

  # sig { returns(String) }
  def head: () -> String

  # sig { returns(URI) }
  def homepage: () -> URI

  # sig { returns(T::Hash) }
  def latest: () -> T::Hash

  # sig { returns(String) }
  def license: () -> String

  # sig { returns(T::Boolean) }
  def main?: () -> T::Boolean

  # sig { returns(T::Boolean) }
  def private?: () -> T::Boolean

  # sig { returns(T::Hash) }
  def release: () -> T::Hash

  # sig { returns(T.nilable(T::Hash)) }
  def repo: () -> T::Hash

  # sig { returns(String) }
  def sha: () -> String

  # sig { returns(String) }
  def sha256: () -> String

  # sig { returns(String) }
  def sort: () -> String

  # sig { returns(T.any(:curl, :homebrew_curl)) }
  def strategy: () -> :curl | :homebrew_curl

  # sig { returns(T.nilable(String)) }
  def tag: () -> String

  # sig { returns(String) }
  def url: () -> String

  # sig { returns(String) }
  def version: () -> String

  # sig { returns(T::Hash[String, String]) }
  def debug: () -> T::Hash[String, String]

  # sig { returns(T::Hash[String, String]) }
  def hash: () -> T::Hash[String, String]

  # sig { returns(String) }
  def to_s: () -> String
end
