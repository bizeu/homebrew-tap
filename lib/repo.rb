# typed: ignore
# frozen_string_literal: true

require "download_strategy"
require "extend/pathname"
require "uri"
require "utils/github"

class Repo
  extend T::Sig

  # @param [String] name
  # Repository Name
  attr_reader :name

  # @param [String] owner
  # Repo Owner
  attr_reader :owner

  # @param [String] url
  # Download URL
  attr_reader :owner

  sig { params(owner: String, name: String).returns(Repo) }
  def initialize(owner, name)
    @owner = owner
    @name = name
    @url = nil
  end
  
  # GitHub API Repos Repository URL.
  #
  # @return [URI] repos:owner/:name url 
  sig { returns(URI) }
  def api
    @api ||= api_repos_url
  end
  
  # Adds Subroutes to GitHub API Repos Repository URL.
  #
  # @subroutes [String] subroutes to add to repos/:owner/:repo/:subroutes
  # @return [URI] url
  sig { params(subroutes: String).returns(URI) }
  def api_repos_url(*subroutes)
     GitHub.url_to("repos", owner, name, *subroutes)
  end

  # Remote Default Branch.
  #
  # @return [String] branch name
  sig { returns(String) }
  def branch
    @branch ||= repo["default_branch"]
  end

  # Download Cache Directory.
  #
  # @return [String] branch name
  sig { returns(Pathname) }
  def cache
    unless downloader.cached_location.exist?
      downloader.shutup!
      downloader.fetch
    end
    downloader.cached_location
  end

  # GitHub Token.
  #
  # @return [T.nilable(String)] token
  sig { returns(T.nilable(String)) }
  def credentials
    @credentials ||= GitHub::API.credentials
  end
  
  sig { returns(String) }
  def desc
    @desc ||= repo["description"]
  end

  # Downloaded Instance for URL.
  #
  # @return [T.any(:curl, :homebrew_curl)] url downloader instance
  sig { returns(T.any(:curl, :homebrew_curl)) }
  def downloader
    @downloader ||= DownloadStrategyDetector.detect_from_symbol(strategy).new(
      url=url, 
      name=name, 
      version=version, 
      meta={headers: ["Accept: application/vnd.github.v3+json", "Authorization: token #{credentials}"], 
      location: true, 
      silent: true}
    )
  end

  # Remote URL from {#github} adding ".git".
  #
  # @return [String] git repository url 
  sig { returns(String) }
  def head
    @head ||= repo["clone_url"]
  end

  # GitHub Repository URL.
  #
  # @return [URI] repository url 
  sig { returns(URI) }
  def homepage
    @homepage ||= URI.parse(["https://github.com", owner, name].join("/"))
  end
    
  # API Repository Latest Tag Hash
  #
  # @return [T::Hash] latest tag hash
  sig { returns(T::Hash) }
  def latest
    @latest ||= GitHub::API.open_rest(api_repos_url "tags").fetch(0, {})
  end
  
  # License SPDX ID.
  #
  # @return [String] license ID
  sig { returns(String) }
  def license
    @license ||= repo["license"].nil? ? "MIT" : repo["license"]["spdx_id"]
  end

  # No Tags in Repository Use Main or --HEAD.
  #
  # @return [T::Boolean] true if no tags
  sig { returns(T::Boolean) }
  def main?
    @head_only ||= tag == "v0.0.0"
  end

  # Is Private Repo?.
  #
  # @return [T::Boolean] repos hash
  sig { returns(T::Boolean) }
  def private?
    @private ||= repo["private"]
  end

  # Latest Release Hash.
  #
  # @return [T::Hash] release hash
  sig { returns(T::Hash) }
  def release 
    @release ||= GitHub.get_latest_release(owner, name)
  rescue GitHub::API::HTTPNotFoundError
    @release = {}
  end

  # Api Repos Response for Repository Name.
  #
  # @return [T.nilable(T::Hash)] repos hash
  sig { returns(T.nilable(T::Hash)) }
  def repo 
    @repo ||= GitHub.repository(owner, name)
  rescue GitHub::API::HTTPNotFoundError
    odie "Repository #{owner}/#{name} not found#{", or no credentials" if credentials.nil?}"
  end
  
  # Commit SHA.
  #
  # @return [String] commit sha
  sig { returns(String) }
  def sha 
    @sha ||= GitHub::API.open_rest(api_repos_url("commits", branch))["sha"]
  rescue GitHub::API::HTTPNotFoundError
    odie "Repository #{owner}/#{name} no commits"
  end 

  # SHA256.
  #
  # @return [String] commit sha
  sig { returns(String) }
  def sha256
    Digest::SHA256.hexdigest(cache.to_s)
  end

  # Short Commit SHA.
  #
  # @return [String] short sha
  sig { returns(String) }
  def sort 
    @sort ||= sha[0..6]
  end 

  # Download Strategy Symbol if Private or Public.
  #
  # @return [T.any(:curl, :homebrew_curl)] :homebrew_curl if private?, :curl otherwise
  sig { returns(T.any(:curl, :homebrew_curl)) }
  def strategy 
    @strategy ||= private? ? :curl : :homebrew_curl
  end 

  # Latest Repository Tag Hash from API
  # When a tag is created
  # When a release is created: 'gh release create $(svu) --generate-notes'
  #
  # @return [T.nilable(String)] latest tag
  sig { returns(T.nilable(String)) }
  def tag
    @tag ||= release.fetch("tag_name", latest.fetch("name", "v0.0.0"))
  end

  # Download url
  # HomebrewCurlDownloadStrategy gives Error if no version argument and version in url, so it requires brew curl 
  #   brew = HomebrewCurlDownloadStrategy.new(url="https://../tarbal/v0.0.0", name="secrets", version="", 
  #          meta={headers: [...], location: true, quiet: true})
  # With version argument and no brew curl 
  #   brew = HomebrewCurlDownloadStrategy.new(url="https://../tarball", 
  #          name="secrets", version="v0.0.0", meta={headers: [...], location: true, silent: true})
  #
  # @return [String] download url
  sig { returns(String) }
  def url
    return @url unless @url.nil?
    
    # TODO: aqui lo dejo, comprobar de nuevo las url con el cambio de symbol y ver por que vacía el downloader
    # TODO: mirar la captura
    
    if strategy == :homebrew_curl
      @url = main? ? api_repos_url("tarball", branch).to_s : release["tarball_url"] || latest["tarball_url"]
    else
      @url = "#{homepage.to_s}/archive/#{main? ? sha : version}.tar.gz"
    end
  end
  
  # Short Commit SHA.
  #
  # @return [String] short sha
  sig { returns(String) }
  def version 
    @version ||= "#{tag}#{"-alpha+#{sha}" if main?}"
  end 

  sig { returns(T::Hash[String, String]) }
  def debug
    {
      repo: repo,
      release: release,
      latest: latest,
      **hash,
    }
  end
  
  sig { returns(T::Hash[String, String]) }
  def hash
    {
      api: api,
      branch: branch,
      cache: cache,
      credentials: credentials,
      desc: desc,
      downloader: downloader,
      head: head,
      homepage: homepage,
      license: license,
      main?: main?,
      name: name,
      owner: owner,
      private?: private?,
      repository: to_s,
      sha: sha,
      sha256: sha256,
      sort: sort,
      strategy: strategy,
      tag: tag,
      url: url,
      version: version,
    }
  end
  
  def to_s
    [owner, name].join("/")
  end
end
