# typed: false
# frozen_string_literal: true

require "formulary"
require "pkg_version"
require "tap"
require 'utils/github'
require 'utils/github/api'

class Header

  # When a release is created: 'gh release create $(svu) --generate-notes'
  # @return [Hash] 
  def _release
    @_release ||= GitHub.get_latest_release(user, name)
  rescue GitHub::API::HTTPNotFoundError
    @_release = nil
  end

  def _repo 
    @_repo ||= GitHub.repository(user, name)
  rescue GitHub::API::HTTPNotFoundError
    odie "Repository #{user}/#{name} not found."
  end
  
  def _sha256
    resource = Resource.new(name)
    resource.url(url) 
    if resource.downloader.cached_location.exist?
      download = resource.downloader.cached_location
    else
      resource.downloader.shutup!
      download = resource.fetch(verify_download_integrity: false)
    end
    download.sha256
  end

  # When a tag is created (and not release)
  # @return [Hash] 
  def _tag
    @_tag ||= GitHub::API.open_rest(GitHub.url_to("repos", user, name, "tags"))[0]
  rescue GitHub::API::HTTPNotFoundError, Error
    @_tag = nil
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
        
  def release_url   
    @release_url ||= _release.nil? ? nil : _release["tarball_url"]
  end

  def release_version
    @release_version ||= _release.nil? ? nil : _release["tag_name"]
  end

  def sha256
    @sha256 ||= _sha256
  end

  def tag_url   
    @tag_url ||= _tag.nil? ? nil : _tag["tarball_url"]
  end

  def tag_version
    @tag_version ||= _tag.nil? ? nil : _tag["name"]
  end
  
  # Instance of {Tap} from {#file}.
  def tap 
    @tap ||= Tap.from_path(@file)
  end
  
  def url
    @url ||= release_url || tag_url || (odie "Tag the repository or use --HEAD: #{homepage}" if !head_only?)
  end

  # The user name of the {Tap} from {#file}. 
  # Usually, it's the GitHub username of the {Tap}'s remote repository.
  def user
    @user ||= tap.user
  end
  
  def version
    @version ||= release_version || tag_version || (odie "Tag the repository or use --HEAD: #{homepage}" if !head_only?)
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
      release_url: release_url,
      release_version: release_version,
      sha256: sha256,
      tag_url: tag_url,
      tag_version: tag_version,
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
