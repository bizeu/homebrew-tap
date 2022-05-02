# typed: false
# frozen_string_literal: true

# require "cask/cask"
require 'cask/exceptions'
require 'cask/installer'
require 'cask/cmd/install'
require 'cli/named_args'
require 'cli/parser'
require 'exceptions'
require 'install'
require 'tap'
require 'uninstall'
require 'upgrade'
require 'utils/github'
require_relative 'taps'

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }

  def formulas_args
    Homebrew::CLI::Parser.new do
      description <<~FORMULAS_DESC
        User/Organization Tap Formulas/Casks.

        Argument can be specified as "<user>`/`<repo>" or "<user>", see `ENVIRONMENT` for defaults.

        Uninstall will be done for the tap unless no formulas in tap (casks and commands will also be removed).


        `brew formulas` [`tap|user`]:
        List `tap` formulas "<user>`/`<repo>`/`<name>" for user, i.e: `brew formulas caarlos0`

        `brew formulas` -i [`tap|user`]:
        Install `tap` formulas "<user>`/`<repo>`/`<name>" for user, i.e: `brew formulas -i caarlos0`

        `brew taps` --all [`tap|user`]:
        List all `taps` formulas "<user>`/`<repo>/`<name>"" for user, i.e: `brew taps --all`

        `brew taps` -i [`tap|user`]:
        Install all `taps` formulas "<user>`/`<repo>/`<name>" for user, i.e: `brew taps -i --all`

        ENVIRONMENT:
          GITHUB_REPOSITORY   "<user>`/`<repo>"
          USER                "<user>"
      FORMULAS_DESC

      switch '-a', '--all',
             description: 'List all formulas <user>`/`<repo>`/`<name> for a user.'

      switch '-i', '--install',
             description: 'Install all formulas for a user.'

      switch '--force',
             description: 'Force overwriting existing files.'

      switch '--ignore-dependencies',
             description: 'An unsupported Homebrew development flag to skip installing any dependencies of any kind. ' \
                          "If the dependencies are not already present, the formula will have issues. If you're not " \
                          'developing Homebrew, consider adjusting your PATH rather than using this flag.'

      switch '-j', '--json',
             description: 'Show output in json.'

      switch '--[no-]quarantine',
             description: 'Disable/enable quarantining of downloads (default: enabled).'

      switch '-r', '-u', '--remove', '--uninstall',
             description: 'Uninstall all.'

      switch '-z', '--zap',
             description: 'Remove all files associated with a cask. May remove files which are shared between applications.'

      conflicts '--install', '--json', '--uninstall'

      named_args %i[tap user], max: 1
    end
  end

  def formula_full_name(tap, value)
    "#{tap.name}/#{File.basename(value, ".rb")}"
  end

  def _formulas_install(name, flag = '--upgrade')
    system "brew install --quiet #{flag} #{name}" if Install.install_formula?(Formulary.factory(name), quiet: true)
  end

  def formulas_install(tap, args)
    begin
      tap.install unless tap.installed?

      named = CLI::NamedArgs.new(*tap.formula_names, *tap.cask_tokens, flags: ['quiet'], cask_options: true)
      formulae, casks  = named.to_formulae_and_casks(prefer_loading_from_api: true)
                              .partition { |formula_or_cask| formula_or_cask.is_a?(Formula) }
      suppress(Cask::CaskAlreadyInstalledError) do
        if casks.any? && OS.mac?
          Cask::Cmd::Install.install_casks(*casks, force: args.force?, quarantine: args.quarantine?, quiet: true)
          system 'sudo xattr -r -d com.apple.quarantine /Applications || true'
        end
      end

      installed_formulae = formulae.select do |f|
        Install.install_formula?(f, head: false, fetch_head: false, force: args.force?, quiet: true)
      end

      return if installed_formulae.empty?

      Install.install_formulae(installed_formulae, force: args.force?, quiet: true)

      Upgrade.check_installed_dependents(installed_formulae, flags: [], force: args.force?, quiet: true)
    rescue FormulaUnreadableError, FormulaClassUnavailableError,
           TapFormulaUnreadableError, TapFormulaClassUnavailableError => e
      warn e.backtrace if Homebrew::EnvConfig.developer?
      ofail e.message
    rescue FormulaOrCaskUnavailableError => e
      if e.name == 'updog'
        ofail "What's updog?"
        nil
      end
    end
    # tap.formula_names.each do |name|
    #   # named = CLI::NamedArgs.new(name, flags: ["quiet"], cask_options: true)
    #   # f, c  = named.to_formulae_and_casks(prefer_loading_from_api: true)
    #   #              .partition { |formula_or_cask| formula_or_cask.is_a?(Formula) }
    #   # ohai f
    #   # ohai c
    #   _formulas_install(name)
    # end
    # if OS.mac?
    #   tap.cask_tokens.each do |name|
    #     named = CLI::NamedArgs.new(name, flags: ["quiet"], cask_options: true)
    #     f, c  = named.to_formulae_and_casks(prefer_loading_from_api: true)
    #                            .partition { |formula_or_cask| formula_or_cask.is_a?(Formula) }
    #     Cask::Cmd::Install.install_casks(*c, quarantine: false, quiet: true)
    #   end
    # end
  end

  def _formulas_uninstall(name)
    system "brew uninstall --force --quiet #{name}" unless Install.install_formula?(Formulary.factory(name), quiet: true)
  end

  def formulas_uninstall(tap, args)
    if tap.installed? && (tap.formula_names.length.positive? || tap.cask_tokens.length.positive?)
      named = CLI::NamedArgs.new(*tap.formula_names, *tap.cask_tokens, flags: %w[quiet force], cask_options: true)
      all_kegs, casks  = named.to_kegs_to_casks(ignore_unavailable: true, all_kegs: true)
      kegs_by_rack = all_kegs.group_by(&:rack)

      Uninstall.uninstall_kegs(kegs_by_rack, casks: casks, force: true, ignore_dependencies: true, named_args: named)
      if args.zap?
        T.unsafe(Cask::Cmd::Zap).zap_casks(*casks, force: true)
      else
        T.unsafe(Cask::Cmd::Uninstall).uninstall_casks(*casks, force: true)
      end
      # formulas = tap.formula_names + tap.cask_tokens
      # formulas.map { |f| f if Install.install_formula?(Formulary.factory(f), quiet: true) }.compact
      #
      # system "brew uninstall --force --quiet #{formulas.join(" ")}"
      # tap.formula_names.each do |name|
      #   _formulas_uninstall(name)
      # end
      # if RUBY_PLATFORM[/darwin/]
      #   tap.cask_tokens.each do |name|
      #     _formulas_uninstall(name)
      #   end
      # end
      system "brew untap --force --quiet #{tap}"
    end
  end

  def formulas_list(tap)
    if tap.installed?
      formulas = tap.formula_names.map { |name| formula_full_name(tap, name) }
      tap.cask_tokens.each { |name| formulas.push(formula_full_name(tap, name)) } if RUBY_PLATFORM[/darwin/]
    else
      formulas = formulas_remote_for_tap(tap)
      if RUBY_PLATFORM[/darwin/]
        formulas.concat(formulas_remote_for_tap(tap, 'Casks'))
      end
    end
    formulas
  end

  def formula_output(value, args)
    if args.json?
      puts JSON.generate(value)
    else
      puts value
    end
  end

  def formulas_remote_for_tap(tap, path = 'Formula')
    uri = GitHub.url_to('repos', tap.full_name, 'contents', path)
    GitHub::API.open_rest(uri).map { |i| formula_full_name(tap, i['name']) if File.extname(i['name']) == '.rb' }.compact
  rescue GitHub::API::HTTPNotFoundError
    []
  end

  def formulas
    tap, args = tap_fetch_and_parse_args(formulas_args)
    #noinspection RubyResolve
    if args.all? && args.install?
      taps_list(tap).each do |t|
        formulas_install(t, args)
      end
    elsif args.install?
      formulas_install(tap, args)
    elsif args.all? && args.uninstall?
      taps_list(tap).each do |t|
        formulas_uninstall(t, args)
      end
      system 'brew autoremove --quiet'
    elsif args.uninstall?
      formulas_uninstall(tap, args)
      system 'brew autoremove --quiet'
    elsif args.all?
      formula_output(taps_list(tap).map { |t| formulas_list(t) }, args)
    else
      formula_output(formulas_list(tap), args)
    end
  end
end
