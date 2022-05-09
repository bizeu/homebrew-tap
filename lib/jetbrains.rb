# typed: ignore
# frozen_string_literal: true

=begin
$ brew pry

JetBrains::NAMES
JetBrains.data
JetBrains.enabled
JetBrains.globals
JetBrains.installs
JetBrains.links
JetBrains.scripts
JetBrains.uninstalls
JetBrains.unlinks

app = JetBrains.new()
JetBrains.new.data
app.data
app.enabled?
JetBrains.new(:Toolbox).install
JetBrains.new(:Idea).link
JetBrains.new(:Toolbox).uninstall
JetBrains.new(:Idea).unlink
app.script

=end

require "cask/config"
require "cli/named_args"
require "extend/pathname"
require "extend/git_repository"
require "json"
require "net/http"
require 'open3'
require "utils/popen"
require "uninstall"
require_relative "reqs"

class JetBrains

  extend T::Sig
  
  DEFAULT ||= :PyCharm
  NAMES ||= {
    AppCode: {enable: OS.mac? ? true : false, code: "AC", requirement: Reqs::AppCode, },
    CLion: {enable: true, code: "CL", requirement: Reqs::CLion, },
    DataGrip: {enable: true, code: "DG", requirement: Reqs::DataGrip, },
    Gateway: {enable: true, code: "GW", app: OS.mac? ? "JetBrains Gateway" : nil, requirement: Reqs::Gateway, },
    GoLand: {enable: true, code: "GO", requirement: Reqs::GoLand, },
    Idea: {enable: true, code: "IIU", app: OS.mac? ? "IntelliJ IDEA" : nil, requirement: Reqs::Idea, },
    PyCharm: {enable: true, code: "PCP", requirement: Reqs::PyCharm, },
    RubyMine: {enable: true, code: "RM", requirement: Reqs::RubyMine, },
    Toolbox: {enable: true, code: "TBA", app: OS.mac? ? "JetBrains Toolbox" : nil, requirement: Reqs::Toolbox, },
    WebStorm: {enable: true, code: "WS", requirement: Reqs::WebStorm, },
  }
  API ||= URI("https://data.services.jetbrains.com/products/releases").freeze
  APPDIR ||= Pathname.new(Cask::Config::DEFAULT_DIRS[:appdir]).freeze
  SHARED ||= Pathname.new("/Users/Shared").freeze
  JETBRAINS ||= (SHARED + name).extend(GitRepositoryExtension).freeze
  REPO ||= URI("http://github.com/#{Tap.from_path(__FILE__).user}/#{name}").freeze
  SCRATCH ||= (JETBRAINS + "scratch").freeze
  CONFIG_INCLUDE ||= %w[codestyles colors fileTemplates filetypes icons inspection jdbc-drivers 
                        keymaps quicklists ssl svg tasks templates tools systemDictionary.dic].freeze
  OPTIONS_EXCLUDE ||= %w[actionSummary find gemmanager javaRuleManager jdk.table osFileIdePreferences 
                         other pluginAdvertiser recentProjects runner.layout updates 
                         usage.statistics window.state].map { |i| "#{i}.xml" }.freeze
  @@data = nil
  @@repo = nil
  
  # Application. 
  attr_reader :name

  def initialize(name = DEFAULT)
    @name = name
  end

  # Data for :app.
  #
  # sig { returns(Hash) }
  def data 
    @data ||= self.class.data[name]
  end
  
  # Class Method for Data for all apps
  #
  # sig { returns(Hash) }
  def self.data
    if @@data.nil?
      bin = Pathname.new(HOMEBREW_PREFIX) + "bin"
      d = NAMES.keys.to_h { |n| [n, { 
        appdir: APPDIR + (NAMES[n].fetch(:app, n.to_s) + (OS.mac? ? ".app" : "")),
        cache: JETBRAINS.join("cache", n.to_s),
        config: JETBRAINS.join("config", n.to_s),
        plugins: JETBRAINS.join("plugins", n.to_s),
      }] }
      for n in NAMES.keys  
        d[n][:contents] = d[n][:appdir] + (OS.mac? ? "Contents" : "") 
        plugins = d[n][:contents] + "plugins"
        d[n][:bin] = d[n][:contents] + "bin"
        d[n][:exe] = { 
          dst: bin + n.to_s.downcase,
          src: (OS.mac? ? d[n][:contents] + "MacOS" : d[n][:bin]) + (n.to_s.downcase + (OS.mac? ? "" : ".sh"))
        }
        d[n][:jedi] = plugins + "terminal/jediterm-bash.in"
        d[n][:options] = d[n][:config] + "options"
        d[n][:other] = d[n][:options] + "other.xml"
        d[n][:properties] = d[n][:config] + ".properties"
        d[n][:vmoptions] = d[n][:config] + ".vmoptions"
        pr = n == :Toolbox ? "jetbrains-" : ""
        d[n][:scripts] = {
          exe: { 
            dst: bin + n.to_s.downcase,
            src: (OS.mac? ? d[n][:contents] + "MacOS" : d[n][:bin]) + (pr + n.to_s.downcase + (OS.mac? ? "" : ".sh")),
          },
          launcher: { 
            dst: bin + (n.to_s.downcase + "-launcher"),
            src: plugins + "remote-dev-server/bin/launcher.sh",
          },
          ltedit: { 
            dst: bin + (n.to_s.downcase + "-ltedit"),
            src: d[n][:bin] + "ltedit.sh",
          },
          remote: { 
            dst: bin + (n.to_s.downcase + "-remote"),
            src: d[n][:bin] + "remote-dev-server.sh",
          },
        }
        if enabled.include? n
          code = NAMES[n][:code]
          uri = URI(API + "?#{{ code: code, latest: true, type: "release",}.to_query}")
          res = Net::HTTP.get_response(uri)
          odie "Failed to get response from #{uri}" unless res.is_a?(Net::HTTPSuccess)
          platform = OS.mac? ? ("mac#{Hardware::CPU.intel? ? "" : "M1"}") : "linux"
          json = JSON.parse(res.body)[code][0]["downloads"][platform]
          d[n][:url] = json["link"]
          res = Net::HTTP.get_response(URI(json["checksumLink"]))
          odie "Failed to get response from #{json["checksumLink"]}" unless res.is_a?(Net::HTTPSuccess)
          d[n][:sha] = res.body.split(" ")[0]
        end
      end
      @@data = d
    end
    @@data
  end

  # Instance Method is app enabled?
  #
  # sig { returns(bool) }
  def enable?
    self.class.enabled.include? name
  end
  
  # Class Method Enabled Applications
  #
  # sig { returns(List[Symbol]) }
  def self.enabled
    @@enable ||= NAMES.map { |name, opts| name if opts[:enable] }.compact
  end

  # Homebrew git wrapper
  #
  def self.git(*args)
    system(Utils::Git::git, "-C", JETBRAINS.dirname, *args)
  end
  
  # Globals for Applications
  #
  # sig { returns(Dict[String, Pathname]) }
  def self.globals
    @@globals ||= NAMES.keys.to_h { |name| [name, { 
      "#{name.upcase}_PROPERTIES": data[name][:properties],
      "#{name.upcase}_VM_OPTIONS": data[name][:vmoptions],
    }] }
  end

  # Install Application if Enabled on Linux, link and scripts for both macOS and Linux
  # JetBrains.new(:Toolbox).install
  # 
  # sig { returns(void) }
  def install
    if ! OS.mac? && enable?
    end
    link
  end 
  
  # Install All Enabled Applications on Linux, link and scripts for both macOS and Linux
  # JetBrains.installs
  # 
  # sig { returns(void) }
  def self.installs 
    for name in NAMES.keys 
      self.new(name).install
    end
    nil
  end
  
  # Links Config for Application except DEFAULT (source)
  # JetBrains.new(:Toolbox).link
  #
  # sig { returns(void) }
  def link
    self.class.repo
    data[:options].mkpath unless data[:options].exist?
    return if name == DEFAULT
    default = self.class.data[DEFAULT]
    
    default[:config].children.each do |src|
      basename = src.basename.to_s
      next unless CONFIG_INCLUDE.include? basename
      dest = data[:config] + basename
      
      if dest.exist? && (!dest.symlink? || dest.realpath != src.realpath)
        opoo "Unlink #{dest}"
        dest.rmtree
      end
      
      if !dest.exist?
        ohai "Link #{dest}"
        dest.make_relative_symlink(src)
      end
    end
    
    default[:options].children.each do |src|
      basename = src.basename.to_s
      next if OPTIONS_EXCLUDE.include? basename
      dest = data[:options] + basename
      
      if dest.exist? && (!dest.symlink? || dest.realpath != src.realpath)
        opoo "Unlink #{dest}"
        dest.rmtree
      end
      
      if !dest.exist?
        ohai "Link #{dest}"
        dest.make_relative_symlink(src)
      end
    end
    nil
  end

  # Links Config for All Application except DEFAULT (source)
  # JetBrains.links
  #
  # sig { returns(void) }
  def self.links
    for name in NAMES.keys 
      self.new(name).link
    end
    nil
  end
  
  # Make SHARED and APPLICATIONS directories for Linux
  #
  # sig { returns(bool) }
  def self.mkdirs
    return if OS.mac?
    [APPDIR, SHARED].each do |d|
      next if d.exist?
      ENV["SUDOC"] = "/usr/bin/sudo"
      odie "mkdir #{d}" unless system("sudo mkdir -p -m ugo+rwx #{d}")
      odie "chown #{d}" unless system("sudo chown -R $(id -u):$(id -g) #{d}")
    end
  end

  # Updates vmoptions and properties for the application
  # JetBrains.new(:Toolbox).property
  #
  # sig { returns(void) }
  def property
    self.class.repo
    
    data[:options].mkpath unless data[:options].exist?
    return if name == DEFAULT
    default = self.class.data[DEFAULT]
    
    default[:config].children.each do |src|
      basename = src.basename.to_s
      next unless CONFIG_INCLUDE.include? basename
      dest = data[:config] + basename
      
      if dest.exist? && (!dest.symlink? || dest.realpath != src.realpath)
        opoo "Unlink #{dest}"
        dest.rmtree
      end
      
      if !dest.exist?
        ohai "Link #{dest}"
        dest.make_relative_symlink(src)
      end
    end
    
    default[:options].children.each do |src|
      basename = src.basename.to_s
      next if OPTIONS_EXCLUDE.include? basename
      dest = data[:options] + basename
      
      if dest.exist? && (!dest.symlink? || dest.realpath != src.realpath)
        opoo "Unlink #{dest}"
        dest.rmtree
      end
      
      if !dest.exist?
        ohai "Link #{dest}"
        dest.make_relative_symlink(src)
      end
    end
    nil
  end

  # Updates vmoptions and properties for all applications
  # JetBrains.links
  #
  # sig { returns(void) }
  def self.properties
    for name in NAMES.keys 
      self.new(name).property
    end
    nil
  end
    
  # Syncs JetBrains Repository
  # Utils::popen_read("git", "log").chomp.presence (for stdout)
  #
  # sig { returns(void) }
  def self.repo
    if @@repo.nil?
      mkdirs
      unless JETBRAINS.git?
        _ = Functions::git("-C #{SHARED} clone --quiet --depth 1 --recursive --branch main #{REPO.to_s}")
      end
      nil
      @@repo = true
    end
  end
  
  # Class Method for depends_on Requirements Block for macOS
  #
  # sig { returns(void) }
  def self.requirements(cls)
    return unless OS.mac?
    for n in enabled
      cls.depends_on NAMES[n][:requirement]
    end
  end

  # Links Scripts for Applications Installed or Removed Existing if No Application 
  #
  # sig { returns(void) }
  def script
    self.class.repo
    data[:scripts].each_value do |s|
      if s[:src].exist?
        s[:dst].make_relative_symlink(s[:src]) unless s[:dst].symlink?
      elsif s[:dst].symlink?
        s[:dst].unlink
      end
    end
    nil
  end
  
  # Links All Scripts for Applications Installed
  #
  # sig { returns(void) }
  def self.scripts
    for name in NAMES.keys 
       self.new(name).script
    end
    nil
  end

  # UnInstall Application if Not Enabled on macOS & Linux
  # JetBrains.new(:Toolbox).uninstall
  # 
  # sig { returns(void) }
  def uninstall
    return if enable?
    if OS.mac?
      cask_name = NAMES[name][:requirement]::NAME.downcase
      cask = Cask::CaskLoader.load(cask_name)
      Functions::cmd("brew uninstall --quiet #{cask_name}") if cask.installed?
    end
    script
  end 
  
  # UnInstall Applications if Not Enabled on macOS & Linux
  # JetBrains.uninstalls
  # 
  # sig { returns(void) }
  def self.uninstalls 
    for name in NAMES.keys 
      self.new(name).uninstall
    end
    nil
  end
  
  # Unlinks Config for Application except DEFAULT (source)
  # JetBrains.new(:Toolbox).unlink 
  # sig { returns(void) }
  def unlink 
    self.class.repo
    data[:options].mkpath unless data[:options].exist?
    return if name == DEFAULT
    
    data[:config].children.each do |dest|
      if dest.symlink?
        opoo "Unlink #{dest}"
        dest.unlink
      end
    end
    
    data[:options].children.each do |dest|
      if dest.symlink?
        opoo "Unlink #{dest}"
        dest.unlink
      end
    end
    nil
  end
  
  def self.unlinks
    for name in NAMES.keys 
      self.new(name).unlink
    end
    nil
  end
  
  def hash
    { 
      name: name,
      data: data,
      enable?: enable?,
      globals: self.class.globals[name],
    }
  end
  
  def to_s 
    name.to_s
  end
end
