# typed: strict
# frozen_string_literal: true

require 'cask/cask_loader'
require 'cask/installer'
require 'commands'
require 'completions'
require 'digest'
require 'formula_installer'
require 'formulary'
require 'tap_constants'
require 'utils/formatter'
require 'utils/git'

# This module provide helper functions
#
# Examples
#   # brew irb
#   Functions::compgen
#   Functions::exists?("git")
#   Functions::satisfy("git", true)
#   Functions::sha256("README.md")
#   Functions::tap!("homebrew/core/git")
module Functions
  extend T::Sig

  COMPLETIONS_BASH ||= (Homebrew::Completions::COMPLETIONS_DIR / 'bash/brew').freeze
  COMPLETIONS_ZSH ||= (Homebrew::Completions::COMPLETIONS_DIR / 'zsh/_brew').freeze

  module_function

  # Executes command returns output if success or exit with stderr
  # thread.value.exitstatus == 0
  #
  #   cmd("git --version")
  #
  # @param [String] command command to execute
  # @return [String] output of command
  def cmd(command)
    Open3.popen3(command) do |_, stdout, stderr, thread|
      return stdout.read.chomp if thread.value.success?

      odie stderr.read.chomp
    end
  rescue Errno::ENOENT => e
    odie e
  end

  # Generate completions file (bash, zsh), updates cached brew subcommands and link taps completions.
  #
  # @param [String] full_name formula full name to add with post install message
  # @param [String] version formula version to add with post install message
  #
  # @return [nil]
  def compgen(full_name = nil, version = nil)
    post_format(full_name, version)

    Homebrew::Completions.link! unless Homebrew::Completions.link_completions?
    Commands.rebuild_commands_completion_list
    commands = Commands.commands(external: true, aliases: true).sort
    [COMPLETIONS_BASH, COMPLETIONS_ZSH].each do |i|
      (i).atomic_write Homebrew::Completions.generate_bash_completion_file(commands)
    rescue StandardError
      nil
    end
    line = "    #{__method__}) _brew_#{__method__} ;;"
    odie "#{COMPLETIONS_BASH}:#{line}" unless COMPLETIONS_BASH.binread.include? line

    ohai "Postinstalled: #{Formatter.success(__method__.to_s)}" unless full_name.nil?
  end

  # Checks if any version of formula is installed.
  #
  #   exists?("Formula/name.rb")
  #
  # @param [String | Pathname] ref formula name or path
  # @return [T::Boolean] true if formula is installed
  def exists?(ref)
    name = ref.to_s.downcase
    tap!(name)
    Formulary.factory(name).any_version_installed?
  end

  # Executes homebrew git command returns output if success or exit with stderr
  #
  # @param [String] arguments arguments to add to git
  # @return [String] output of git command
  def git(arguments)
    cmd("#{Utils::Git.git} #{arguments}")
  end

  # Common Post Install Start Message for Formulas with Header.
  #
  # @param [String | nil] full_name formula full name to add with post install message
  # @param [String | nil] version formula version to add with post install message
  # @return [nil]
  def post_format(full_name = nil, version = nil)
    ohai "Postinstalling #{Formatter.identifier(full_name)} #{version}" unless full_name.nil?
  end

  # Install Cask or Formula if not Installed (and its container tap if not installed).
  #
  # @param [String | Pathname] ref formula name or path
  # @param [T::Boolean] formula true if cask, false for formula
  # @return [T::Boolean] true if formula is installed
  def satisfy(ref, formula: true)
    ohai "hola"
    name = ref.to_s.downcase
    if formula
      begin
        Homebrew::Install.install_formulae(Formulary.factory(name), quiet: true) unless exists?(name)
      rescue StandardError
        odie "Formula '#{name}'"
      end
      exists?(name)
    else
      tap!(name)
      # noinspection RubyResolve
      cask = Cask::CaskLoader.load(name)
      unless cask.installed?
        begin
          Cask::Installer.new(cask, quarantine: false, quiet: true).install
        rescue StandardError
          odie "Cask '#{name}'"
        end
      end
      cask.installed?
    end
  end

  # File SHA256 Hexdigest.
  #
  # @param [String | Pathname] path the path to the file
  # @return [String] file sha256 hexdigest
  def sha256(path)
    # noinspection RubyResolve
    Digest::SHA256.file(path).hexdigest
  end

  # Tap it if not tapped.
  #
  # @param [String | Pathname] ref formula/cask name or path
  # @return [nil]
  def tap!(ref)
    name = ref.to_s.downcase
    return unless File.exist?(name)
    return unless name !~ HOMEBREW_TAP_FORMULA_REGEX

    tap = Tap.fetch(Regexp.last_match(1), Regexp.last_match(2))
    tap.install(quiet: true) unless tap.installed?
  end
end
