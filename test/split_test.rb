require 'test_helper'

module Tilia
  class SplitTest < Minitest::Test
    def test_split
      {
        # input                       expected result
        '/foo/bar'                 => ['/foo', 'bar'],
        '/foo/bar/'                => ['/foo', 'bar'],
        'foo/bar/'                 => ['foo', 'bar'],
        'foo/bar'                  => ['foo', 'bar'],
        'foo/bar/baz'              => ['foo/bar', 'baz'],
        'foo/bar/baz/'             => ['foo/bar', 'baz'],
        'foo'                      => ['', 'foo'],
        'foo/'                     => ['', 'foo'],
        '/foo/'                    => ['', 'foo'],
        '/foo'                     => ['', 'foo'],
        ''                         => ['', ''],

        # UTF-8
        "/\xC3\xA0fo\xC3\xB3/bar"  => ["/\xC3\xA0fo\xC3\xB3", 'bar'],
        "/\xC3\xA0foo/b\xC3\xBCr/" => ["/\xC3\xA0foo", "b\xC3\xBCr"],
        "foo/\xC3\xA0\xC3\xBCr"    => ['foo', "\xC3\xA0\xC3\xBCr"]
      }.each do |input, expected|
        assert_equal(expected, Uri.split(input))
      end
    end
  end
end
