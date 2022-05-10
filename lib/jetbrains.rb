# typed: ignore
# frozen_string_literal: true

=begin
$ brew pry

JetBrains::NAMES
JetBrains.data
JetBrains.enabled
JetBrains.service
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
    AppCode: {
      enable: OS.mac? ? true : false, code: "AC", requirement: Reqs::AppCode, Xms: 256, Xmx: 2500,
    },
    CLion: {
      enable: true, code: "CL", requirement: Reqs::CLion, Xms: 256, Xmx: 2000, 
    },
    DataGrip: {
      enable: true, code: "DG", requirement: Reqs::DataGrip, Xms: 128, Xmx: 750,
    },
    Gateway: {
      enable: true, code: "GW", app: OS.mac? ? "JetBrains Gateway" : nil, 
      requirement: Reqs::Gateway, Xms: 128, Xmx: 750, 
    },
    GoLand: {
      enable: true, code: "GO", requirement: Reqs::GoLand, Xms: 128, Xmx: 750, 
    },
    Idea: {
      enable: true, code: "IIU", app: OS.mac? ? "IntelliJ IDEA" : nil, 
      requirement: Reqs::Idea, Xms: 256, Xmx: 4096,
    },
    PyCharm: {
      enable: true, code: "PCP", requirement: Reqs::PyCharm, Xms: 256, Xmx: 4096, 
    },
    RubyMine: {
      enable: true, code: "RM", requirement: Reqs::RubyMine, Xms: 256, Xmx: 2000,
    },
    Toolbox: {
      enable: true, code: "TBA", app: OS.mac? ? "JetBrains Toolbox" : nil, 
      requirement: Reqs::Toolbox, Xms: 128, Xmx: 750, 
    },
    WebStorm: {
      enable: true, code: "WS", requirement: Reqs::WebStorm, Xms: 256, Xmx: 2000
    },
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
  PATCH_JEDI ||= true
  SERVICE ||= HOMEBREW_PREFIX + "etc/profile.d/jet-service"
  
  #!!! AQUI LO DEJOOOOOOOO Cambiando el nombre a jet !!!!!!!!!!!!!!! y todos los name.... 

  SERVICEDIR ||= Pathname.new(Cask::Config::DEFAULT_DIRS[:servicedir]).freeze
  SERVICEFILE ||= (SERVICEDIR + "homebrew.mxcl.jet.plist").freeze # <--
#   TAP ||= Tap.from_path(Pathname.new(__FILE__).sub("cmd", "Formula")).freeze
#   TAPUSER ||= TAP.user.freeze
#   CONFIG ||= URI("http://github.com/#{TAPUSER}/JetBrains").freeze
  
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
        log: JETBRAINS.join("log", n.to_s),
        plugins: JETBRAINS.join("plugins", n.to_s),
      }] }
      
      for n in NAMES.keys
        lower = n.to_s.downcase

        d[n][:contents] = d[n][:appdir] + (OS.mac? ? "Contents" : "") 
        plugins = d[n][:contents] + "plugins"
        d[n][:bin] = d[n][:contents] + "bin"
        d[n][:exe] = { 
          dst: bin + lower,
          src: (OS.mac? ? d[n][:contents] + "MacOS" : d[n][:bin]) + (lower + (OS.mac? ? "" : ".sh"))
        }
        d[n][:jedi] = plugins + "terminal/jediterm-bash.in"
        d[n][:options] = d[n][:config] + "options"
        d[n][:other] = d[n][:options] + "other.xml"
        d[n][:properties] = d[n][:config] + ".properties"
        d[n][:vmoptions] = d[n][:config] + ".vmoptions"
        d[n][:Xms] = OS.mac? ? NAMES[n][:Xms] : 128
        d[n][:Xmx] = OS.mac? ? NAMES[n][:Xmx] : 750
        
        pr = n == :Toolbox ? "jetbrains-" : ""
        remote_dev_server = d[n][:bin] + "remote-dev-server.sh"
        d[n][:scripts] = {
          exe: { 
            dst: bin + lower,
            src: (OS.mac? ? d[n][:contents] + "MacOS" : d[n][:bin]) + (pr + lower + (OS.mac? ? "" : ".sh")),
          },
          ltedit: { 
            dst: bin + (lower + "-ltedit"),
            src: d[n][:bin] + "ltedit.sh",
          },
          remote: { 
            dst: bin + (lower + "-remote"),
            src: remote_dev_server.exist? ? script_remote(n, d[n][:plugins].to_s, remote_dev_server.to_s) : nil,
          },
          remote_dev_server: { 
            dst: bin + (lower + "-remote-dev-server"),
            src: remote_dev_server,
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
  def self.service
    content = NAMES.keys.map { |v| 
      "export #{v.upcase}_PROPERTIES='#{data[v][:properties]}'
export #{v.upcase}_VM_OPTIONS='#{data[v][:vmoptions]}'\n" if NAMES[v][:enable]}.compact.join()
    old_content = SERVICE.exist? ? SERVICE.binread : ""
    unless old_content.eql?(content)
      ohai "Write #{SERVICE}"
      SERVICE.atomic_write content
    end
    if OS.mac? && !SERVICE.exist?
      #Aqui lo deo estaba cambiando el nombre a JET y su tap. 
      # TODO: sudo pero no se si se hace el link en el caso del xml no del sh, o sea, que tengo que
      #  ver el directorio de instalación del servicio. Y tambien que se ponga a restart; true
    end
  end

  # Patch Jedi Term for Application
  #
  # sig { returns(void) }
  def jedi
    return unless data[:jedi].exist?
    ext = data[:jedi].extname
    bak = data[:jedi].sub_ext("#{ext}.bak")
    content=". /etc/profile"
    
    if PATCH_JEDI
      FileUtils.cp(data[:jedi], bak) unless bak.exist?
      unless data[:jedi].binread.eql?(content)
        ohai "Patch #{data[:jedi]}"
        data[:jedi].atomic_write content
      end
    else
      if data[:jedi].binread.eql?(content)
        ohai "Restore #{data[:jedi]}"
        FileUtils.cp(bak, data[:jedi]) 
      end
    end
  end

  # Patch Jedi Term for All Applications
  # JetBrains.installs
  # 
  # sig { returns(void) }
  def self.jedis 
    for name in NAMES.keys 
      self.new(name).jedi
    end
    nil
  end
  
  # Install Application if Enabled on Linux, link and scripts for both macOS and Linux
  # JetBrains.new(:Toolbox).install
  # 
  # sig { returns(void) }
  def install
    if ! OS.mac? && enable?
    end
    jedi
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
    service

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
      
      if dest.exist? && (!dest.symlink? || src.realpath != dest.realpath)
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
      
      if dest.exist? && (!dest.symlink? || src.realpath != dest.realpath)
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
  
  # Properties 
  #
  # sig { returns(String) }
  def properties
    <<~COMPLETION
    idea.config.path=#{data[:config]}
    idea.plugins.path=#{data[:plugins]}
    idea.scratch.path=#{SCRATCH}
    idea.system.path=#{data[:cache]}
    idea.log.path=#{data[:log]}
    idea.max.intellisense.filesize=2500
    idea.max.content.load.filesize=20000
    idea.cycle.buffer.size=disabled
    idea.no.launcher=false
    idea.dynamic.classpath=false
    #idea.ProcessCanceledException=disabled
    idea.popup.weight=heavy
    sun.java2d.d3d=false
    swing.bufferPerWindow=true
    sun.java2d.pmoffscreen=false
    sun.java2d.uiScale.enabled=true
    javax.swing.rebaseCssSizeMap=true
    ide.mac.useNativeClipboard=True
    #idea.max.vcs.loaded.size.kb=20480
    #idea.chooser.lookup.for.project.dirs=false
    idea.true.smooth.scrolling=true
    idea.fatal.error.notification=disabled
    com.apple.mrj.application.live-resize=false
    apple.laf.useScreenMenuBar=true
    apple.awt.fileDialogForDirectories=true
    apple.awt.graphics.UseQuartz=true
    apple.awt.fullscreencapturealldisplays=false
    COMPLETION
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
      if s[:src].instance_of?(Pathname)
        if s[:src].exist? && ( (s[:dst].symlink? && s[:src].realpath != s[:dst].realpath) || (!s[:dst].symlink? && s[:dst].exist?) )
          opoo "Unlink #{s[:dst]}"
          s[:dst].unlink
        end
        
        if !s[:src].exist? && ( s[:dst].exist? || s[:dst].symlink? )
          opoo "Unlink #{s[:dst]}"
          s[:dst].unlink
        end
        
        if s[:src].exist? && !s[:dst].exist?
          ohai "Link #{s[:dst]}"
          s[:dst].make_relative_symlink(s[:src])
        end
      else
        if s[:src].nil?
          if s[:dst].exist?
            ohai "Removing #{s[:dst]}"
            s[:dst].unlink
          end
        else
          old_content = s[:dst].exist? ? s[:dst].binread : ""
          unless old_content.eql?(s[:src])
            ohai "Write #{s[:dst]}"
            s[:dst].atomic_write s[:src]
            s[:dst].chmod(0755)
          end
        end
      end
    end
    nil
  end
  
  # <application>-remote script to install plugins in remote application for a project
  #
  # sig { returns(void) }
  def self.script_remote(symbol, plugins, remote_dev_server)
      <<~SCRIPT_REMOTE
#!/bin/sh
# shellcheck disable=SC2046

#
# installs plugins for project in #{symbol.to_s} remote dev server

set -eu

#META_DIRECTORY="/Users/Shared/JetBrains/plugins/PyCharm/meta"
META_DIRECTORY="#{plugins}/meta"

ids() {
  find "${META_DIRECTORY}" -mindepth 1 -maxdepth 1 -type f -name "*.json" -exec basename "{}" .json \; | sort -h;
}

list() {
  while read -r id; do
    printf '%s - ' "${id}"; jq -r .name "${META_DIRECTORY}/${id}.json"
  done
}

for arg; do
  shift
  case "${arg}" in
    --all) set -- "$@" $(ids) ; break ;;
    -h|--help|help)
      cat <<EOF
usage: ${0##*/} /path/to/project --all|<plugin> [<plugin>...]
   or: ${0##*/} ids
   or: ${0##*/} names

installs plugins for project in #{symbol.to_s} remote dev server

commands:
  -h, --help, help        show this help and exit
  ids                     show all IDs of the local installed plugins
  names                   show all IDs and names of the local installed plugins
  <plugin> [<plugin>...]  to install the specified plugins on the remote

options:
  --all                   to install all local plugins on the remote for the project
EOF
      exit 0
      ;;
    ids) ids; exit 0 ;;
    list) ids | list; exit 0 ;;
    *) set -- "$@" "${arg}";;
  esac
done

#{remote_dev_server} installPlugins "$@"
SCRIPT_REMOTE
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

  # VM Options for Application 
  # AppCode, CLion: -Xss, -XX:NewSize, -XX:MaxNewSize
  #
  # sig { returns(String) }
  def vmoptions
    <<~VMOPTIONS
    -Xms#{data[:Xms]}m
    -Xmx#{data[:Xmx]}m
    -XX:ReservedCodeCacheSize=512m
    -Xss2m
    -XX:NewSize=128m
    -XX:MaxNewSize=128m
    -XX:+IgnoreUnrecognizedVMOptions
    -XX:+UseG1GC
    -XX:SoftRefLRUPolicyMSPerMB=50
    -XX:CICompilerCount=2
    -XX:+HeapDumpOnOutOfMemoryError
    -XX:-OmitStackTraceInFastThrow
    -ea
    -Dsun.io.useCanonCaches=false
    -Djdk.http.auth.tunneling.disabledSchemes=""
    -Djdk.attach.allowAttachSelf=true
    -Djdk.module.illegalAccess.silent=true
    -Dkotlinx.coroutines.debug=off
    -XX:ErrorFile=/tmp/java_error_in_idea_%p.log
    -XX:HeapDumpPath=/tmp/java_error_in_idea_%p.hprof
    VMOPTIONS
  end
  
  # Updates properties and vmoptions for the application
  # JetBrains.new(:Toolbox).write
  #
  # sig { returns(void) }
  def write
    self.class.repo
    [:properties, :vmoptions].each do |type|
      content = send(type.to_s)
      old_content = data[type].exist? ? data[type].binread : ""
      unless old_content.eql?(content)
        ohai "Write #{data[type]}"
        data[type].atomic_write content
      end
    end
    nil
  end

  # Updates properties and vmoptions for all applications
  # JetBrains.writes
  #
  # sig { returns(void) }
  def self.writes
    for name in NAMES.keys 
      self.new(name).write
    end
    nil
  end
  
  def hash
    { 
      name: name,
      data: data,
      enable?: enable?,
    }
  end
  
  def to_s 
    name.to_s
  end
end
