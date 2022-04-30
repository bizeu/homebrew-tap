# typed: false
# frozen_string_literal: true

require 'cmd/autoremove'
require_relative 'header'

class AutoFormula < Formula
  extend T::Sig

  def initialize(path, spec, alias_path: nil, force_bottle: false)
    @header = Header.new(method(:initialize).source_location[0])
    super(path, spec, alias_path: nil, force_bottle: false)
  end
  
  desc header.desc
  homepage header.homepage
  url header.url
  sha256 header.sha256
  license header.license
  version header.version
  head header.head, branch: header.branch 

  def verify_download_integrity(_fn)
    false
  end

  def post_install
    autoremove
  end
end
