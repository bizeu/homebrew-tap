# typed: ignore
# frozen_string_literal: true

require 'global'
require 'cask/config'
require 'cli/named_args'
require 'extend/pathname'
require 'extend/git_repository'
require 'json'
require 'net/http'
require 'open3'
require 'tap'
require 'utils/popen'
require 'uninstall'
require_relative 'reqs'

# This modules provides functionality to manage JetBrains products.
#
# Examples:
#
#   # $ brew pry
#   JetBrains::NAMES
#   JetBrains.data
#   JetBrains.enabled
#   JetBrains.service
#   JetBrains.installs
#   JetBrains.links
#   JetBrains.scripts
#   JetBrains.uninstalls
#   JetBrains.unlinks
#
#   app = JetBrains.new()
#   JetBrains.new.data
#   app.data
#   app.enabled?
#   JetBrains.new(:Toolbox).install
#   JetBrains.new(:Idea).link
#   JetBrains.new(:Toolbox).uninstall
#   JetBrains.new(:Idea).unlink
#   app.script
class JetBrains

  extend T::Sig

  DEFAULT ||= :PyCharm
  NAMES ||= {
    AppCode: {
      enable: OS.mac? ? true : false, code: 'AC', requirement: Reqs::AppCode, Xms: 256, Xmx: 2500
    },
    CLion: {
      enable: true, code: 'CL', requirement: Reqs::CLion, Xms: 256, Xmx: 2000
    },
    DataGrip: {
      enable: true, code: 'DG', requirement: Reqs::DataGrip, Xms: 128, Xmx: 750
    },
    Gateway: {
      enable: true, code: 'GW', app: OS.mac? ? 'JetBrains Gateway' : nil,
      requirement: Reqs::Gateway, Xms: 128, Xmx: 750
    },
    GoLand: {
      enable: true, code: 'GO', requirement: Reqs::GoLand, Xms: 128, Xmx: 750
    },
    Idea: {
      enable: true, code: 'IIU', app: OS.mac? ? 'IntelliJ IDEA' : nil,
      requirement: Reqs::Idea, Xms: 256, Xmx: 4096
    },
    PyCharm: {
      enable: true, code: 'PCP', requirement: Reqs::PyCharm, Xms: 256, Xmx: 4096
    },
    RubyMine: {
      enable: true, code: 'RM', requirement: Reqs::RubyMine, Xms: 256, Xmx: 2000
    },
    Toolbox: {
      enable: true, code: 'TBA', app: OS.mac? ? 'JetBrains Toolbox' : nil,
      requirement: Reqs::Toolbox, Xms: 128, Xmx: 750
    },
    WebStorm: {
      enable: true, code: 'WS', requirement: Reqs::WebStorm, Xms: 256, Xmx: 2000
    }
  }.freeze
=begin
CONFIG_INCLUDE ||= %w[codestyles colors fileTemplates filetypes icons inspection jdbc-drivers
                        keymaps quicklists ssl svg tasks templates tools systemDictionary.dic].freeze
OPTIONS_EXCLUDE ||= %w[actionSummary editor gemmanager javaRuleManager jdk.table
                         other osFileIdePreferences recentProjects runner.layout updates
                         window.state].freeze
=end

=begin
======CONFIG_EXCLUDE
ssl
======CONFIG_EXCLUDE
=end

=begin
======OPTIONS_INCLUDE
a-file-icons
actionSummary
advancedSettings
applicationLibraries
asciidoc
atom-icon-associations
aws
baseRefactoring
bashsupport-pro
bashsupport-pro-folding
bashsupport-pro.local
cachedDictionary
codestream
color-highlighter
colors.scheme
completion.factors.user
completionMLRanking
console-font
csv-plugin
customization
customPostfixTemplates
databaseDrivers
diff
docker
docker-registry
editor
editor-font
features.usage.statistics
FeatureSuggester
fileEditorProviderManager
FilenameTemplateSettings
git_toolbox_2
github
github-copilot
github-copilot.local
GitLink
grazie_global
highlightTokenConfiguration-v2
ide-features-trainer
ide.general
ignore
images.support
IntelliLang
intentionSettings
javaeeExternalResources
javaRuleManager
jdk.table
laf
log_highlighting
mac
MachineLearningCompletion
macros
magic-group
markdown
material_custom_theme
material_theme
MultiHighlight
nativeTerminalPlugin
NoteStashUserSettings
notifications
one_dark_config
orchide-app
osFileIdePreferences
PackageRequirementsSettings
packages
path.macros
pluginAdvertiser
postfixTemplates
project.default
projectView
pycrunch-jetbrains
PyDocumentationSettings
pySdk
pyWelcome
quick-file-preview
rainbow-csv
rainbow_brackets
remote-servers
ReSTService
rInterpreterSettings
runner.layout
scratch_config
security
send-2-terminal-settings
shared-indexes
shownTips
smartsearch
sonarlint
sshConfigs
stringManipulation
templates
terminal
TestRunnerService
trusted-paths
ui
ui.lnf
uml
usage.statistics
usageView
vcs
watcherDefaultTasks
web-browsers
web-types-npm-loader
web-types-registry
webServers

======OPTIONS_INCLUDE
=end
  API ||= URI.parse('https://data.services.jetbrains.com/products/releases').freeze
  APPDIR ||= Pathname.new(Cask::Config::DEFAULT_DIRS[:appdir]).freeze
  SHARED ||= Pathname.new('/Volumes/USB-2TB/Shared').freeze
  JETBRAINS ||= (SHARED + name).extend(GitRepositoryExtension).freeze
  REPO ||= URI("https://github.com/j5pu/#{name}").freeze
  SCRATCH ||= (JETBRAINS / 'scratch').freeze
  CONFIG_INCLUDE ||= %w[codestyles colors fileTemplates filetypes icons inspection jdbc-drivers
                        keymaps quicklists svg tasks templates tools systemDictionary.dic].freeze
  OPTIONS_EXCLUDE ||= %w[
    debugger
    filetypes
    find
    gemmanager
    lightEdit
    nodejs
    other
    overrideFileTypes
    profilerRunConfigurations
    recentProjects
    updates
    window.state
  ].map { |i| "#{i}.xml" }.freeze
  PATCH_JEDI ||= true
  SERVICE ||= HOMEBREW_PREFIX / 'etc/profile.d/jet-service'

  # !!! AQUI LO DEJOOOOOOOO Cambiando el nombre a jet !!!!!!!!!!!!!!! y todos los name....

  SERVICEDIR ||= Pathname.new(Cask::Config::DEFAULT_DIRS[:servicedir]).freeze
  SERVICEFILE ||= (SERVICEDIR / 'homebrew.mxcl.jet.plist').freeze # <--
# TAP ||= Tap.from_path(Pathname.new(__FILE__).sub("cmd", "Formula")).freeze
# TAPUSER ||= TAP.user.freeze
# CONFIG ||= URI("http://github.com/#{TAPUSER}/JetBrains").freeze

  # Application Name
  attr_reader :name

  # Data for {#name} for {JetBrains}
  #
  # @param [Symbol] name command to execute
  # @return [nil]
  def initialize(name = DEFAULT)
    @name = name
  end

  # Data for Application.
  #
  # @return [Hash]
  def data
    @data ||= self.class.data[name]
  end

  # Class Method for Data for all apps
  #
  # @return [Hash[Symbol, void]]
  def self.data
    if @@data.nil?
      bin = Pathname.new(HOMEBREW_PREFIX) / 'bin'
      d = NAMES.keys.to_h do |n|
        [
          n, {
            appdir: APPDIR / (NAMES[n].fetch(:app, n.to_s) + (OS.mac? ? '.app' : '')),
            cache: JETBRAINS.join('cache', n.to_s),
            config: JETBRAINS.join('config', n.to_s),
            log: JETBRAINS.join('log', n.to_s),
            plugins: JETBRAINS.join('plugins', n.to_s)
          }
        ]
      end

      NAMES.each_key do |n|
        lower = n.to_s.downcase

        d[n][:contents] = d[n][:appdir] + (OS.mac? ? 'Contents' : '')
        plugins = d[n][:contents] / 'plugins'
        d[n][:bin] = d[n][:contents] / 'bin'
        d[n][:exe] = {
          dst: bin + lower,
          src: (OS.mac? ? d[n][:contents] / 'MacOS' : d[n][:bin]) + (lower + (OS.mac? ? '' : '.sh'))
        }
        d[n][:jedi] = plugins / 'terminal/jediterm-bash.in'
        d[n][:options] = d[n][:config] / 'options'
        d[n][:other] = d[n][:options] / 'other.xml'
        d[n][:properties] = d[n][:config] / '.properties'
        d[n][:vmoptions] = d[n][:config] / '.vmoptions'
        d[n][:Xms] = OS.mac? ? NAMES[n][:Xms] : 128
        d[n][:Xmx] = OS.mac? ? NAMES[n][:Xmx] : 750

        pr = n == :Toolbox ? 'jetbrains-' : ''
        remote_dev_server = d[n][:bin] / 'remote-dev-server.sh'
        d[n][:scripts] = {
          exe: {
            dst: bin + lower,
            src: (OS.mac? ? d[n][:contents] / 'MacOS' : d[n][:bin]) + (pr + lower + (OS.mac? ? '' : '.sh'))
          },
          ltedit: {
            dst: bin + (lower / '-ltedit'),
            src: d[n][:bin] / 'ltedit.sh'
          },
          remote: {
            dst: bin + (lower / '-remote'),
            src: remote_dev_server.exist? ? script_remote(n, d[n][:plugins].to_s, remote_dev_server.to_s) : nil
          },
          remote_dev_server: {
            dst: bin + (lower / '-remote-dev-server'),
            src: remote_dev_server
          }
        }

        next unless enabled.include? n

        code = NAMES[n][:code]
        uri = URI(API + "?#{{ code:, latest: true, type: 'release' }.to_query}")
        res = Net::HTTP.get_response(uri)
        odie "Failed to get response from #{uri}" unless res.is_a?(Net::HTTPSuccess)
        platform = if OS.mac?
                     "mac#{Hardware::CPU.intel? ? '' : 'M1'}"
                   else
                     'linux'
                   end
        json = JSON.parse(res.body)[code][0]['downloads'][platform]
        d[n][:url] = json['link']
        res = Net::HTTP.get_response(URI(json['checksumLink']))
        odie "Failed to get response from #{json['checksumLink']}" unless res.is_a?(Net::HTTPSuccess)
        d[n][:sha] = res.body.split(' ')[0]
      end
      @@data = d
    end
    @@data
  end

  # Instance Method is app enabled?
  #
  # @return [Boolean]
  def enable?
    self.class.enabled.include? name
  end

  # Class Method Enabled Applications
  #
  # @return [Array[Symbol]]
  def self.enabled
    @@enable ||= NAMES.map { |name, opts| name if opts[:enable] }.compact
  end

  # Homebrew git wrapper
  #
  # @return [T::Boolean]
  def self.git(*args)
    system(Utils::Git.git, '-C', JETBRAINS.dirname, *args)
  end

  # Globals for Applications
  #
  # @return [nil]
  def self.service
    content = NAMES.keys.map do |v|
      "export #{v.upcase}_PROPERTIES='#{data[v][:properties]}'
export #{v.upcase}_VM_OPTIONS='#{data[v][:vmoptions]}'\n" if NAMES[v][:enable]
end .compact.join
    old_content = SERVICE.exist? ? SERVICE.binread : ''
    unless old_content.eql?(content)
      ohai "Write #{SERVICE}"
      SERVICE.atomic_write content
    end
    if OS.mac? && !SERVICE.exist?
      # Aqui lo deo estaba cambiando el nombre a JET y su tap.
      # TODO: sudo pero no se si se hace el link en el caso del xml no del sh, o sea, que tengo que
      #  ver el directorio de instalación del servicio. Y también que se ponga a restart; true
    end
  end

  # Patch Jedi Term for Application
  #
  # @return [nil]
  def jedi
    return unless data[:jedi].exist?

    ext = data[:jedi].extname
    bak = data[:jedi].sub_ext("#{ext}.bak")
    content = '. /etc/profile'

    if PATCH_JEDI
      FileUtils.cp(data[:jedi], bak) unless bak.exist?
      unless data[:jedi].binread.eql?(content)
        ohai "Patch #{data[:jedi]}"
        data[:jedi].atomic_write content
      end
    elsif data[:jedi].binread.eql?(content)
      ohai "Restore #{data[:jedi]}"
        FileUtils.cp(bak, data[:jedi])
    end
  end

  # Patch Jedi Term for All Applications
  # JetBrains.installs
  #
  # @return [nil]
  def self.jedis
    NAMES.keys.cycle(1) { |name| new(name).jedi }
  end

  # Install Application if Enabled on Linux, link and scripts for both macOS and Linux
  # JetBrains.new(:Toolbox).install

  # @return [nil]
  def install
    # if ! OS.mac? && enable?
    # end
    jedi
    link
  end

  # Install All Enabled Applications on Linux, link and scripts for both macOS and Linux
  # JetBrains.installs

  # @return [nil]
  def self.installs
    NAMES.each_key do |name|
      new(name).install
    end
    service

    nil
  end

  # Links Config for Application except DEFAULT (source)
  # JetBrains.new(:Toolbox).link
  #
  # @return [nil]
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

      unless dest.exist?
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

      unless dest.exist?
        ohai "Link #{dest}"
        dest.make_relative_symlink(src)
      end
    end
    nil
  end

  # Links Config for All Application except DEFAULT (source)
  # JetBrains.links
  #
  # @return [nil]
  def self.links
    NAMES.each_key do |name|
      new(name).link
    end
    nil
  end

  # Make SHARED and APPLICATIONS directories for Linux
  #
  # @return [nil]
  def self.mkdirs
    return if OS.mac?

    [APPDIR, SHARED].each do |d|
      next if d.exist?

      ENV['SUDOC'] = '/usr/bin/sudo'
      odie "mkdir #{d}" unless system("sudo mkdir -p -m ugo+rwx #{d}")
      odie "chown #{d}" unless system("sudo chown -R $(id -u):$(id -g) #{d}")
    end
  end

  # Properties
  #
  # @return [String]
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
  # @return [Boolean]
  def self.repo
    if @@repo.nil?
      mkdirs
      unless JETBRAINS.git?
        _ = Functions.git("-C #{SHARED} clone --quiet --depth 1 --recursive --branch main #{REPO}")
      end
      @@repo = true
    end
  end

  # Class Method for depends_on Requirements Block for macOS
  #
  # sig { returns(void) }
  # @return [nil]
  def self.requirements(cls)
    return unless OS.mac?

    enabled.each do |n|
      cls.depends_on NAMES[n][:requirement]
    end
  end

  # Links Scripts for Applications Installed or Removed Existing if No Application
  #
  # @return [nil]
  def script
    self.class.repo
    data[:scripts].each_value do |s|
      if s[:src].instance_of?(Pathname)
        if s[:src].exist? && ((s[:dst].symlink? && s[:src].realpath != s[:dst].realpath) || (!s[:dst].symlink? && s[:dst].exist?) )
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
      elsif s[:src].nil?
        if s[:dst].exist?
            ohai "Removing #{s[:dst]}"
            s[:dst].unlink
          end
        else
          old_content = s[:dst].exist? ? s[:dst].binread : ''
          unless old_content.eql?(s[:src])
            ohai "Write #{s[:dst]}"
            s[:dst].atomic_write s[:src]
            s[:dst].chmod(0755)
          end
      end
    end
    nil
  end

  # <application>-remote script to install plugins in remote application for a project
  #
  # @param [Symbol] symbol of the application
  # @param [String] path to the application plugins meta directory
  # @param [String] remote_dev_server executable path
  # @return [String]
  def self.script_remote(symbol, plugins, remote_dev_server)
    <<~SCRIPT_REMOTE
      #!/bin/sh
      # shellcheck disable=SC2046

      #
      # installs plugins for project in #{symbol} remote dev server

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

      installs plugins for project in #{symbol} remote dev server

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
  # @return [nil]
  def self.scripts
    NAMES.each_key do |name|
      new(name).script
    end
    nil
  end

  # UnInstall Application if Not Enabled on macOS & Linux
  # JetBrains.new(:Toolbox).uninstall

  # @return [nil]
  def uninstall
    return if enable?

    if OS.mac?
      cask_name = NAMES[name][:requirement]::NAME.downcase
      # noinspection RubyResolve
      cask = Cask::CaskLoader.load(cask_name)
      Functions.cmd("brew uninstall --quiet #{cask_name}") if cask.installed?
    end
    script
  end

  # UnInstall Applications if Not Enabled on macOS & Linux
  # JetBrains.uninstalls

  # @return [nil]
  def self.uninstalls
    NAMES.each_key do |name|
      new(name).uninstall
    end
    nil
  end

  # Unlinks Config for Application except DEFAULT (source)
  # JetBrains.new(:Toolbox).unlink

  # @return [nil]
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

  # Unlinks Config for All Applications except DEFAULT (source)
  # JetBrains.new(:Toolbox).unlink

  # @return [nil]
  def self.unlinks
    NAMES.each_key do |name|
      new(name).unlink
    end
    nil
  end

  # VM Options for Application
  # AppCode, CLion: -Xss, -XX:NewSize, -XX:MaxNewSize
  #
  # @return [String]
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
  # @return [nil]
  def write
    self.class.repo
    %i[properties vmoptions].each do |type|
      content = send(type.to_s)
      old_content = data[type].exist? ? data[type].binread : ''
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
  # @return [nil]
  def self.writes
    NAMES.each_key do |name|
      new(name).write
    end
    nil
  end

  # Hash With Instance Representation.
  #
  # @return [Hash[Symbol, void]]
  def to_hash
    {
      name:,
      data:,
      enable?: enable?
    }
  end

  def to_s
    name.to_s
  end
end

JetBrains.writes
