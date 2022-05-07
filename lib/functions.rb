# typed: true
# frozen_string_literal: true

=begin
$ brew pry
Functions::sha256("README.md")
=end

require "cask/cask_loader"
require "cask/installer"
require "digest"
require "formula_installer"
require "formulary"
require "tap_constants"

module Functions
  extend T::Sig
  
  module_function

  # Install Cask or Formula if not Installed (and its container tap if not installed).
  #
  # @param [String] ref formula/cask name or path
  # @param [bool] cask true if cask, false for formula
  # @return [bool] true if cask/formula is installed
  def satisfy(ref, formula = true)
    # TODO: command satisfy que asi no hay que preguntar si esta o no esta. 
    name = ref.to_s.downcase
    
    if !File.exist?(name) && name =~ HOMEBREW_TAP_FORMULA_REGEX
      tap = Tap.fetch(Regexp.last_match(1), Regexp.last_match(2))
      tap.install(quiet: true) unless tap.installed?
    end
    
    if formula
      formula = Formulary.factory(name)
      unless formula.any_version_installed?
        Homebrew::Install.install_formulae(formula, quiet: true)
      end
      formula.any_version_installed?
    else
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
end
