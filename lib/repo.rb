=begin
This module contains the Repo class.

Examples

  # brew pry
  r = Repo.new("j5pu", "bats"); r.hash      #=> main
  r = Repo.new("j5pu", "secrets"); r.hash   #=> tag (private) => url: api
  r = Repo.new("bizeu", "release"); r.hash  #=> main (private) => url: api
  r = Repo.new("j5pu", "bindev"); r.hash    #=> tag
  r = Repo.new("bizeu", "shts"); r.hash     #=> release and tag (private) => url: api
=end
require "download_strategy"
require "extend/pathname"
require "uri"
require "utils/github"

require_relative "functions"

class Repo
  extend T::Sig

  # Repository Name
  # 
  attr_reader :name

  # Repository Owner
  # 
  attr_reader :user

  def initialize(user, name)
    @user = user
    @name = name
    @url = nil
  end
  
  # GitHub API Repos Repository URL.
  #
  # @return [URI] repos:user/:name url 
  def api
    @api ||= api_repos_url
  end
  
  # Adds Subroutes to GitHub API Repos Repository URL.
  #
  # @param [String] subroutes to add to repos/:user/:repo/:subroutes
  # @return [URI] url
  def api_repos_url(*subroutes)
     GitHub.url_to("repos", user, name, *subroutes)
  end

  # Remote Default Branch.
  #
  # @return [String] branch name
  def branch
    @branch ||= repo["default_branch"]
  end

  # Download Cache Directory.
  #
  # @return [Pathname] cache directory
  def cache
    unless downloader.cached_location.exist?
      downloader.shutup!
      downloader.fetch
    end
    downloader.cached_location
  end

  # GitHub Token.
  #
  # @return [String | nil] token
  def credentials
    @credentials ||= GitHub::API.credentials
  end
  
  # Repository Description.
  #
  # @return [String] repository description
  def desc
    @desc ||= repo["description"]
  end

  # Downloaded Instance for URL.
  #
  # @return [FossilDownloadStrategy | CurlDownloadStrategy | HomebrewCurlDownloadStrategy)] url downloader instance
  def downloader
    @downloader ||= DownloadStrategyDetector.detect_from_symbol(strategy).new(
      url, 
      name, 
      version, 
      **headers, location: true, silent: true,
    )
  end

  # Request Headers with Authentication.
  #
  # @return [Hash[Symbol, Array[String]]] headers
  def headers
    if strategy == :homebrew_curl
      @headers ||= { headers: ["Accept: application/vnd.github.v3+json", "Authorization: token #{credentials}"]}
    else 
      @headers ||= {}
    end
  end
  
  # Remote URL from {#github} adding ".git".
  #
  # @return [String] git repository url 
  def head
    @head ||= repo["clone_url"]
  end
  
  # GitHub Repository URL.
  #
  # @return [URI] repository url 
  def homepage
    @homepage ||= URI.parse(["https://github.com", user, name].join("/"))
  end
    
  # API Repository Latest Tag Hash
  #
  # @return [T::Hash] latest tag hash
  def latest
    @latest ||= GitHub::API.open_rest(api_repos_url "tags").fetch(0, {})
  end
  
  # License SPDX ID.
  #
  # @return [String] license ID
  def license
    @license ||= repo["license"].nil? ? "MIT" : repo["license"]["spdx_id"]
  end

  # No Tags in Repository Use Main or --HEAD.
  #
  # @return [Boolean] true if no tags
  def main?
    @head_only ||= tag == "v0.0.0"
  end

  # Is Private Repo?.
  #
  # @return [Boolean] repos hash
  def private?
    @private ||= repo["private"]
  end

  # Latest Release Hash.
  #
  # @return [Hash] release hash
  def release 
    @release ||= GitHub.get_latest_release(user, name)
  rescue GitHub::API::HTTPNotFoundError
    @release = {}
  end

  # Api Repos Response for Repository Name.
  #
  # @return [T::Hash] repos hash
  def repo 
    @repo ||= GitHub.repository(user, name)
  rescue GitHub::API::HTTPNotFoundError
    odie "Repository #{user}/#{name} not found#{", or no credentials" if credentials.nil?}"
  end
  
  # Commit SHA.
  #
  # @return [String] commit sha
  def sha 
    @sha ||= GitHub::API.open_rest(api_repos_url("commits", branch))["sha"]
  rescue GitHub::API::HTTPNotFoundError
    odie "Repository #{user}/#{name} no commits"
  end 

  # SHA256.
  #
  # @return [String] commit sha
  def sha256
    Functions::sha256(cache.to_s)
  end

  # Short Commit SHA.
  #
  # @return [T::String] short sha
  def sort 
    @sort ||= sha[0..6]
  end 

  # Download Strategy Symbol if Private or Public.
  #
  # @return [:curl | :homebrew_curl] :homebrew_curl if private?, :curl otherwise
  def strategy 
    @strategy ||= private? ? :homebrew_curl : :curl 
  end 

  # Latest Repository Tag Hash from API
  # When a tag is created
  # When a release is created: 'gh release create $(svu) --generate-notes'
  #
  # @return [T.nilable(String)] latest tag
  def tag
    @tag ||= latest.fetch("name", "v0.0.0")
  end

  # Download url
  # 
  # HomebrewCurlDownloadStrategy gives Error if no version argument and version in url, so it requires brew curl 
  #   brew = HomebrewCurlDownloadStrategy.new(url="https://../tarbal/v0.0.0", name="secrets", version="", 
  #          meta={headers: [...], location: true, quiet: true})
  # With version argument and no brew curl 
  #   brew = HomebrewCurlDownloadStrategy.new(url="https://../tarball", 
  #          name="secrets", version="v0.0.0", meta={headers: [...], location: true, silent: true})
  #
  # @return [String] download url
  def url
    if strategy == :homebrew_curl
      @url = main? ? api_repos_url("tarball", branch).to_s : latest["tarball_url"]
    else
      @url = "#{homepage.to_s}/archive/#{main? ? sha : version}.tar.gz"
    end
  end
  
  # Version.
  #
  # @return [T::String] version
  def version 
    @version ||= "#{tag}#{"-alpha+#{sha}" if main?}"
  end 

  def debug
    {
      repo: repo,
      release: release,
      latest: latest,
      downloader: downloader,
      **hash,
    }
  end
  
  # Hash With Instance Representation.
  #
  # @return [Hash[Symbol, void]]
  def to_hash
    {
      api: api,
      branch: branch,
      cache: cache,
      credentials: credentials,
      desc: desc,
      head: head,
      homepage: homepage,
      license: license,
      main?: main?,
      name: name,
      private?: private?,
      repository: to_s,
      sha: sha,
      sha256: sha256,
      sort: sort,
      strategy: strategy,
      tag: tag,
      url: url,
      user: user,
      version: version,
    }
  end
  
  def to_s
    [user, name].join("/")
  end
end
