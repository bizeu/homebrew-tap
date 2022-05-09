# typed: strict
# sig/repo.rbs

class Repo
  attr_reader name: String
  attr_reader user: String
  def initialize: (user: String, name: String) -> nil
  def api: () -> URI
  def api_repos_url: (*subroutes: String) -> URI
  def branch: () -> String
  def cache: () -> Pathname
  def credentials: () -> String?
  def desc: () -> String
  def downloader: () -> CurlDownloadStrategy | HomebrewCurlDownloadStrategy
  def head: () -> String
  def homepage: () -> URI
  def latest: () -> Hash
  def license: () -> String
  def main?: () -> Boolean
  def private?: () -> Boolean
  def release: () -> Hash
  def repo: () -> Hash
  def sha: () -> String
  def sha256: () -> String
  def sort: () -> String
  def strategy: () -> :curl | :homebrew_curl
  def tag: () -> String
  def url: () -> String
  def version: () -> String
  def debug: () -> Hash[String, String]
  def hash: () -> Hash[String, String]
  def to_s: () -> String
end
