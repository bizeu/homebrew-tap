# typed: ignore
# frozen_string_literal: true

=begin
$ brew pry

h = Header.new("Casks/bats.rb"); h.hash        # main
h = Header.new("Formula/bats.rb"); h.hash      # main
h = Header.new("Formula/binsh.rb"); h.hash     # main
h = Header.new("Formula/secrets.rb"); h.hash   # tag (private) => url: api
=end

require "date"
require "tap"
require "uri"
require 'utils/github'
require 'utils/github/api'

require_relative "repo"

class Header
  extend T::Sig

  # It's the same as {#name} in {Formula}.
  attr_reader :file
  
  # The fully-qualified name of the {Formula}.
  # For core formula it's the same as {#name}.
  # e.g. `homebrew/tap-name/this-formula`
  attr_reader :full_name

  # The name of the {Formula} from basename of {#file}. 
  # It is the same as {#name} of the {Formula}.
  # e.g. `this-formula`
  attr_reader :name

  # Instance of {Repo} from {#file}.
  attr_reader :repo

  # Instance of {Tap} from {#file}.
  attr_reader :tap
  
  # The user name of the {Tap} from {#file}. 
  # Usually, it's the GitHub username of the {Tap}'s remote repository.
  attr_reader :user
  
  def initialize(file = nil)
    @file = Pathname.new(file || caller(1).first.split(":")[0]).realpath
    @tap = Tap.from_path(@file)
    @full_name = @tap.formula_file_to_name(@file)
    @user = @tap.user
    odie "#{@full_name} not supported: #{@full_name}" if @tap.core_tap?
    @name ||= @full_name.split("/").last
    @repo = Repo.new(@user, @name)
  end

  # Fills Formula Header
  #
  # sig { returns(bool) }
  def self.run(file, cls)
    header = new(file)
    
    cls.desc header.desc
    cls.homepage header.homepage
    cls.url header.url, **header.using
    cls.sha256 header.sha256
    cls.license header.license
    cls.version header.version
    cls.head header.head, branch: header.branch 
  end
  
  # Remote Default Branch.
  #
  # @return [String] branch name
  def branch
    @branch ||= repo.branch
  end

  # Is cask?
  #
  # sig { returns(bool) }
  def cask?
    file.to_s.include? "/Casks/"
  end

  # Repository Description.
  #
  # @return [String] token
  def desc
    @desc ||= repo.desc
  end

  # Is formula?
  #
  # sig { returns(bool) }
  def formula?
    file.to_s.include? "/Formula/"
  end

  # Remote URL from {#github} adding ".git".
  #
  # @return [String] git repository url 
  def head
    @head ||= repo.head
  end

  # GitHub Repository URL.
  #
  # @return [String] repository url 
  def homepage
    @homepage ||= repo.homepage.to_s
  end

  # License SPDX ID.
  #
  # @return [String] license ID
  def license
    @license ||= repo.license
  end

  # SHA256.
  #
  # @return [String] commit sha
  def sha256
    @sha256 ||= repo.sha256
  end

  # Download Strategy Symbol if Private or Public.
  #
  # @return [:curl | :homebrew_curl] :homebrew_curl if private?, :curl otherwise
  def strategy
    @strategy ||= repo.strategy
  end

  # Download url
  #
  # @return [String] download url
  def url
    @url ||= repo.url
  end


  # Strategy Specification for URL Download in Formula.
  #
  # @return [Hash[Symbol, :curl | :homebrew_curl]] :homebrew_curl if private?, :curl otherwise
  def using
    @using ||= { using: repo.strategy }
  end

  # Version.
  #
  # @return [String] version
  def version
    @version ||= repo.version
  end

  def hash
    {
      branch: branch,
      cask?: cask?,
      desc: desc,
      file: file.to_s,
      formula?: formula?,
      full_name: full_name,
      head: head,
      homepage: homepage,
      license: license,
      name: name,
      sha256: sha256,
      strategy: strategy,
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
