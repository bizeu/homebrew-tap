# typed: false
# frozen_string_literal: true

require "date"
require "tap"
require 'utils/github'
require 'utils/github/api'

class Header
  extend T::Sig

  sig { returns(Hash) }
  def _repo 
    @_repo ||= GitHub.repository(user, name)
  rescue GitHub::API::HTTPNotFoundError
    odie "Repository #{user}/#{name} not found."
  end
  
  sig { returns(String) }
  def _sha256
    resource = Resource.new(name)
    resource.url(url_version[:url])
    if resource.downloader.cached_location.exist?
      download = resource.downloader.cached_location
    else
      resource.downloader.shutup!
      download = resource.fetch(verify_download_integrity: false)
    end
    download.sha256
  end

  # When a tag is created
  # When a release is created: 'gh release create $(svu) --generate-notes'
  sig { returns(T.nilable(Hash)) }
  def _tag
    @_tag ||= GitHub::API.open_rest(GitHub.url_to("repos", user, name, "tags"))[0]
  rescue GitHub::API::HTTPNotFoundError, Error
    @_tag = nil
  end
  
  # which has the latest version from release or tag (if there was a release, but latter was tagged only)
  sig { returns(T::Hash[String, T::Bool]) }
  def _url_version
    if _tag.nil?
      version = "v0.0.0-alpha+#{sha}"
      suffix = "archive/#{sha}.tar.gz"
    else
      version = _tag["name"]
      suffix = "archive/#{version}.tar.gz"
    end

    { url: "#{homepage}/#{suffix}", version: version, }
  end

  # @param [String] file
  # It's the same as {#name} in {Formula}.
  attr_reader :file

  sig { params(file: T.nilable(String)).returns(Header)}
  def initialize(file = nil)
    @file = Pathname.new(file || caller(1).first.split(":")[0])
  end
  
  sig { returns(String) }
  def branch
    @branch ||= _repo["default_branch"]
  end
  
  # Is cask?
  sig { returns(T::Boolean) }
  def cask?
    @cask? ||= file.to_s.include?("/Casks/")
  end

  sig { returns(String) }
  def desc
    @desc ||= _repo["description"]
  end

  def fetch_main
    resource = Resource.new(name)
    resource.url(url) 
    resource.downloader.shutup!
    download = resource.fetch(verify_download_integrity: false)    
  end
  
  # Is formula?
  sig { returns(T::Boolean) }
  def formula?
    @formula? ||= file.to_s.include?("/Formula/")
  end
  
  # The fully-qualified name of the {Formula}.
  # For core formula it's the same as {#name}.
  # e.g. `homebrew/tap-name/this-formula`
  sig { returns(String) }
  def full_name 
    @full_name ||= tap.formula_file_to_name(@file)
  end
  
  # Remote URL from {#github} adding ".git".
  sig { returns(String) }
  def head
    @head ||= _repo["clone_url"]
  end

  sig { returns(T::Boolean) }
  def head_only?
    @head_only ||= _tag.nil?
  end

  # GitHub URL of the {Formula} from {#user} and {#name}.
  sig { returns(String) }
  def homepage
    @homepage ||= _repo["html_url"]
  end

  sig { returns(String) }
  def license
    @license ||= _repo["license"]["spdx_id"]
  end

  # The name of the {Formula} from basename of {#file}. 
  # It is the same as {#name} of the {Formula}.
  # e.g. `this-formula`
  sig { returns(String) }
  def name
    odie "#{tap.full_name} not supported: #{full_name}" if tap.core_tap?
    @name ||= full_name.split("/").last
  end

  sig { returns(T::Boolean) }
  def private?
    @private ||= _repo["private"]
  end

  def sha 
    @sha ||= GitHub::API.open_rest(GitHub.url_to("repos", user, name, "commits", branch))["sha"][0..6]
  end 
  
  sig { returns(String) }
  def sha256
    @sha256 ||= _sha256
  end

  # Instance of {Tap} from {#file}.
  sig { returns(Tap) }
  def tap 
    @tap ||= Tap.from_path(@file)
  end
  
  sig { returns(String) }
  def url
    @url ||= url_version[:url]
  end

  sig { returns(String) }
  def url_version
    @url_version ||= _url_version
  end

  # The user name of the {Tap} from {#file}. 
  # Usually, it's the GitHub username of the {Tap}'s remote repository.
  sig { returns(String) }
  def user
    @user ||= tap.user
  end
  
  sig { returns(String) }
  def version
    @version ||= url_version[:version]
  end

  sig { returns(T::Hash[String, String]) }
  def hash
    {
      branch: branch,
      cask?: cask?,
      desc: desc,
      file: file.to_s,
      formula?: formula?,
      full_name: full_name,
      head: head,
      head_only?: head_only?,
      homepage: homepage,
      license: license,
      name: name,
      private?: private?,
      sha256: sha256,
      tap: tap.to_s,
      url: url,
      user: user,
      version: version,
    }
  end
  
  def to_s
    hash.to_s
  end
end
