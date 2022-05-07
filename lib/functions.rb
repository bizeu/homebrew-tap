# typed: true
# frozen_string_literal: true

=begin
$ brew pry
Functions::sha256("README.md")
=end

require "digest"

module Functions
  extend T::Sig
  
  module_function

  # File SHA256 Hexdigest.
  #
  # @param [String] path the path to the file
  # @return [String] file sha256 hexdigest
  def sha256(path)
    Digest::SHA256.file(path).hexdigest
  end  
end
