# typed: false
# frozen_string_literal: true

require "tap"
require 'utils/github'
require 'utils/github/api'

class Header

  # @return [Hash]
  def _repo 
    @_repo ||= GitHub.repository(user, name)
  rescue GitHub::API::HTTPNotFoundError
    odie "Repository #{user}/#{name} not found."
  end
  
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
  # @return [Hash]
  def _tag
    @_tag ||= GitHub::API.open_rest(GitHub.url_to("repos", user, name, "tags"))[0]
  rescue GitHub::API::HTTPNotFoundError, Error
    @_tag = nil
  end
  
  # which has the latest version from release or tag (if there was a release, but latter was tagged only)
  def _url_version
    if _tag.nil?
      opoo "No tag in repository, using default tarball url and v0.0.0, use --HEAD or tag to be updated: #{homepage}"
      suffix = "tarball/#{default_branch}"
      version = "v0.0.0"
    else
      version = _tag["name"]
      suffix = "archive/#{version}.tar.gz"
    end

    { url: "#{homepage}/#{suffix}", version: version, }
  end

  # @param [String] file
  # It's the same as {#name} in {Formula}.
  attr_reader :file

  def initialize(file = nil)
    @file = Pathname.new(file || __FILE__)
  end
  
  def branch
    @branch ||= _repo["default_branch"]
  end

  def desc
    @desc ||= _repo["description"]
  end

  # The fully-qualified name of the {Formula}.
  # For core formula it's the same as {#name}.
  # e.g. `homebrew/tap-name/this-formula`
  def full_name 
    @full_name ||= tap.formula_file_to_name(@file)
  end
  
  # Remote URL from {#github} adding ".git".
  def head
    @head ||= _repo["clone_url"]
  end

  # GitHub URL of the {Formula} from {#user} and {#name}.
  def homepage
    @homepage ||= _repo["html_url"]
  end

  def license
    @license ||= _repo["license"]["spdx_id"]
  end

  # The name of the {Formula} from basename of {#file}. 
  # It is the same as {#name} of the {Formula}.
  # e.g. `this-formula`
  def name
    odie "#{tap.full_name} not supported: #{full_name}" if tap.core_tap?
    @name ||= full_name.split("/").last
  end

  def private?
    @private ||= _repo["private"]
  end

  def sha256
    @sha256 ||= _sha256
  end

  # Instance of {Tap} from {#file}.
  def tap 
    @tap ||= Tap.from_path(@file)
  end
  
  def url
    @url ||= url_version[:url]
  end

  def url_version
    @url_version ||= _url_version
  end

  # The user name of the {Tap} from {#file}. 
  # Usually, it's the GitHub username of the {Tap}'s remote repository.
  def user
    @user ||= tap.user
  end
  
  def version
    @version ||= url_version[:version]
  end

  def hash
    {
      branch: branch,
      desc: desc,
      file: file.to_s,
      full_name: full_name,
      head: head,
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
