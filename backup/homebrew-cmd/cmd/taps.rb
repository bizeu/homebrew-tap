# typed: true
# frozen_string_literal: true

require 'cli/parser'
require 'tap'
require 'utils/github'

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }

  ENV['GIT_QUIET'] = '1'

  def taps_args
    Homebrew::CLI::Parser.new do
      description <<~TAPS_DESC
        User/Organization taps.

        Argument can be specified as "<user>`/`<repo>" or "<user>", see `ENVIRONMENT` for defaults.

        `brew taps` [`tap|user`]:
        List all `installed` taps "<user>`/`<repo>" for user, i.e: `brew taps caarlos0`

        `brew taps` --all [`tap|user`]:
        List all `GitHub` taps "<user>`/`<repo>" for user, i.e: `brew taps --all`

        `brew taps` --tap [`tap|user`]:
        `Tap all` GitHub taps for user.

        `brew taps` --path [`tap|user`]:
        Show tap `path`, defaults from `ENVIRONMENT` or `tap` for repo, i.e: `brew taps caarlos0/tap --path`.

        ENVIRONMENT:
          GITHUB_REPOSITORY   "<user>`/`<repo>"
          USER                "<user>"
      TAPS_DESC

      switch '-a', '--all',
             description: 'List GitHub taps full names <user>`/`<repo>.'

      switch '--force',
             description: 'Force overwriting existing files.'

      switch '--ignore-dependencies',
             description: 'An unsupported Homebrew development flag to skip installing any dependencies of any kind. ' \
                          "If the dependencies are not already present, the formula will have issues. If you're not " \
                          'developing Homebrew, consider adjusting your PATH rather than using this flag.'

      switch '--[no-]quarantine',
             description: 'Disable/enable quarantining of downloads (default: enabled).'

      switch '-p', '--path',
             description: 'Show path for <user>`/`<repo>.'

      switch '-t', '--tap',
             description: 'Tap all GitHub taps for user.'

      switch '-z', '--zap',
             description: 'Remove all files associated with a cask. May remove files which are shared between applications.'

      conflicts '--all', '--path', '--tap'

      named_args %i[tap formula cask user], max: 1
    end
  end

  def tap_fetch_and_parse_args(args)
    args = args.parse
    tap = ENV['GITHUB_REPOSITORY'] ? Tap.fetch(ENV['GITHUB_REPOSITORY']) : Tap.fetch(ENV['USER'], 'tap')
    unless args.no_named?
      tap = if args.named.first.include? '/'
              Tap.fetch(args.named.first)
            else
              Tap.fetch(args.named.first, tap.repo)
            end
    end
    [tap, args]
  end

  def _taps_list(tap, result)
    result.map { |repo| Tap.fetch(tap.user, repo['name']) if repo['name'].start_with?('homebrew-') }.compact
  end

  def taps_list(tap)
    all = []
    type = if GitHub::API.open_rest(GitHub.url_to('users', tap.user))['type'] == 'User'
             'users'
           else
             'orgs'
           end
    GitHub::API.paginate_rest(GitHub.url_to(type, tap.user, 'repos')) do |result|
      all.concat(_taps_list(tap, result))
    end
    all
  end

  def taps
    tap, args = tap_fetch_and_parse_args(taps_args)
    if args.all?
      puts taps_list(tap)
    elsif  args.path?
      puts tap.path
    elsif args.tap?
      taps_list(tap).map { |t| t.install unless t.installed? }
    else
      puts(Tap.select { |t| t.user == tap.user })
    end
  end
end

