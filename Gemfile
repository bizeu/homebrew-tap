# frozen_string_literal: true

source "https://rubygems.org"


# installed gems (should all be require: false)
gem "bootsnap", require: true
gem "byebug", require: true
gem "json_schemer", require: true
gem "minitest", require: true
gem "parallel_tests", require: true
gem "ronn", require: true
gem "rspec", require: true
gem "rspec-github", require: true
gem "rspec-its", require: true
gem "rspec_junit_formatter", require: true
gem "rspec-retry", require: true
gem "rspec-wait", require: true
gem "rubocop", require: true
gem "rubocop-ast", require: true
gem "simplecov", require: true
gem "simplecov-cobertura", require: true
gem "warning", require: true

group :sorbet, optional: false do
  gem "parlour", require: true
  gem "rspec-sorbet", require: true
  gem "sorbet", require: true
  gem "sorbet-runtime", require: true
  gem "tapioca", require: true
end

# vendored gems
gem "activesupport", "< 7" # 7 requires Ruby 2.7
gem "concurrent-ruby"
gem "mechanize"
gem "patchelf"
gem "plist"
gem "rubocop-performance"
gem "rubocop-rails"
gem "rubocop-rspec"
gem "rubocop-sorbet"
gem "ruby-macho"
gem "sorbet-runtime-stub"

# mine
gem "bundler"
gem "pry"
gem "rdoc"  # https://bbs.archlinux.org/viewtopic.php?id=274348
