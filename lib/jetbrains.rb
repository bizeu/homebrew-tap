# typed: ignore
# frozen_string_literal: true

=begin
$ brew pry

JetBrains::NAMES
JetBrains.data
JetBrains.enabled
JetBrains.globals
JetBrains.scripts

app = JetBrains.new()
app.data
app.enabled?
app.script

=end

require "cask/config"
require "extend/pathname"
require "extend/git_repository"
require "json"
require "net/http"
require "utils/git"
require "utils/popen"

require_relative "reqs"

class JetBrains

  extend T::Sig
  
  DEFAULT ||= :PyCharm
  NAMES ||= {
    AppCode: {enable: OS.mac? ? true : false, code: "AC", requirement: Reqs::AppCode, },
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
  SHARED ||= Pathname.new("/Users/Shared/mierda").freeze
  JETBRAINS ||= (SHARED + name).extend(GitRepositoryExtension).freeze
  REPO ||= URI("http://github.com/#{Tap.from_path(__FILE__).user}/#{name}").freeze
  SCRATCH ||= (JETBRAINS + "scratch").freeze
  @@data = nil
  
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

  # Syncs JetBrains Repository
  # Utils::popen_read("git", "log").chomp.presence (for stdout)
  # sig { returns(void) }
  def self.repo
    mkdirs
    unless JETBRAINS.git?
      ok = system(Utils::Git::git, "-C", SHARED, "clone", 
                  "--quiet", "--depth", "1", "--branch", "main", REPO.to_s)
      odie "Cloning: #{JETBRAINS}" unless ok
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
    data[:scripts].each_value do |s|
      if s[:src].exist?
        s[:dst].make_relative_symlink(s[:src]) unless s[:dst].symlink?
      elsif s[:dst].symlink?
        s[:dst].unlink
      end
    end
  end
  
  # Links All Scripts for Applications Installed
  #
  # sig { returns(void) }
  def self.scripts
    for name in NAMES.keys 
       self.new(name).script
    end
  end
  
  def to_s 
    name.to_s
  end
end
