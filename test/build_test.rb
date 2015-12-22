require 'test_helper'

module Tilia
  class BuildTest < Minitest::Test
    def test_build
      [
        'http://example.org/',
        'http://example.org/foo/bar',
        '//example.org/foo/bar',
        '/foo/bar',
        'http://example.org:81/',
        'http://user@example.org:81/',
        'http://example.org:81/hi?a=b',
        'http://example.org:81/hi?a=b#c=d',
        # '//example.org:81/hi?a=b#c=d',  Currently fails due to a
        # PHP bug.
        '/hi?a=b#c=d',
        '?a=b#c=d',
        '#c=d'
      ].each do |value|
        assert_equal(value, Uri.build(Uri.parse(value)))
      end
    end
  end
end
