# typed: true
# frozen_string_literal: true

=begin
$ brew pry

Functions::compgen
Functions::exists?("git")
Functions::satisfy("git", true)
Functions::sha256("README.md")
Functions::tap!("homebrew/core/git")
=end

require "cask/cask_loader"
require "cask/installer"
require "commands"
require "completions"
require "digest"
require "formula_installer"
require "formulary"
require "tap_constants"
require "utils/formatter"

module Functions
  extend T::Sig
  
  COMPLETIONS_BASH ||= (Homebrew::Completions::COMPLETIONS_DIR/"bash/brew").freeze
  COMPLETIONS_ZSH ||= (Homebrew::Completions::COMPLETIONS_DIR/"zsh/_brew").freeze
  
  module_function

  # Generate completions file (bash, zsh), updates cached brew subcommands and link taps completions.
  #
  # @param [String] full_name formula full name to add with post install message
  # @param [version] version formula version to add with post install message
  # @return [void]
  def compgen(full_name = nil, version = nil)
    post_format(full_name, version)

    Homebrew::Completions.link! unless Homebrew::Completions.link_completions?
    Commands.rebuild_commands_completion_list
    commands = Commands.commands(external: true, aliases: true).sort
    for i in [COMPLETIONS_BASH, COMPLETIONS_ZSH]
      begin
        (i).atomic_write Homebrew::Completions.generate_bash_completion_file(commands)
      rescue
        nil
      end
    end
    line = "    #{__method__.to_s}) _brew_#{__method__.to_s} ;;"
    odie "#{COMPLETIONS_BASH}:#{line}" unless COMPLETIONS_BASH.binread.include? line
    
    ohai "Postinstalled: #{Formatter.success(__method__.to_s)}" unless full_name.nil?
  end

  # Checks if any version of formula is installed.
  #
  # @param [String] ref formula name or path
  # @return [bool] true if formula is installed
  def exists?(ref)
    name = ref.to_s.downcase
    tap!(name)
#     if !File.exist?(name) && name =~ HOMEBREW_TAP_FORMULA_REGEX
#       tap = Tap.fetch(Regexp.last_match(1), Regexp.last_match(2))
#       tap.install(quiet: true) unless tap.installed?
#     end
    Formulary.factory(name).any_version_installed?
  end
  
  # Common Post Install Start Message for Formulas with Header.
  #
  # @param [String] full_name formula full name to add with post install message
  # @param [version] version formula version to add with post install message
  # @return [void]
  def post_format(full_name = nil, version = nil)
    ohai "Postinstalling #{Formatter.identifier(full_name)} #{version}" unless full_name.nil?
  end

  # Install Cask or Formula if not Installed (and its container tap if not installed).
  #
  # @param [String] ref formula/cask name or path
  # @param [bool] cask true if cask, false for formula
  # @return [bool] true if cask/formula is installed
  def satisfy(ref, formula = true)
    name = ref.to_s.downcase
#     if !File.exist?(name) && name =~ HOMEBREW_TAP_FORMULA_REGEX
#       tap = Tap.fetch(Regexp.last_match(1), Regexp.last_match(2))
#       tap.install(quiet: true) unless tap.installed?
#     end
    if formula
      Homebrew::Install.install_formulae(Formulary.factory(name), quiet: true) unless exists?(name)
      exists?(name)
#       formula = Formulary.factory(name)
#       unless formula.any_version_installed?
#         Homebrew::Install.install_formulae(formula, quiet: true)
#       end
#       formula.any_version_installed?
    else
      tap!(name)
      cask = Cask::CaskLoader.load(name)
      unless cask.installed?
        Cask::Installer.new(cask, quarantine: false, quiet: true).install
      end
      cask.installed?
    end
  end
  
  # File SHA256 Hexdigest.
  #
  # @param [String] path the path to the file
  # @return [String] file sha256 hexdigest
  def sha256(path)
    Digest::SHA256.file(path).hexdigest
  end
  
  # Tap if not tapped.
  #
  # @param [String] ref formula/cask name or path
  # @return [void]
  def tap!(ref)
    name = ref.to_s.downcase
    
    if !File.exist?(name) && name =~ HOMEBREW_TAP_FORMULA_REGEX
      tap = Tap.fetch(Regexp.last_match(1), Regexp.last_match(2))
      tap.install(quiet: true) unless tap.installed?
    end
  end
end
