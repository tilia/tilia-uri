require 'test_helper'

module Tilia
  class NormalizeTest < Minitest::Test
    def test_normalize
      {
        'http://example.org/' =>             'http://example.org/',
        'HTTP://www.EXAMPLE.com/' =>         'http://www.example.com/',
        'http://example.org/%7Eevert' =>     'http://example.org/~evert',
        'http://example.org/./evert' =>      'http://example.org/evert',
        'http://example.org/../evert' =>     'http://example.org/evert',
        'http://example.org/foo/../evert' => 'http://example.org/evert',
        '/%41' =>                            '/A',
        '/%3F' =>                            '/%3F',
        '/%3f' =>                            '/%3F',
        'http://example.org' =>              'http://example.org/',
        'http://example.org:/' =>            'http://example.org/',
        'http://example.org:80/' =>          'http://example.org/'
      }.each do |input, output|
        assert_equal(output, Uri.normalize(input))
      end
    end
  end
end
