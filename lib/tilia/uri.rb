# Namespace for tilia project
module Tilia
  # Load active support core extensions
  require 'active_support'
  require 'active_support/core_ext'

  require 'uri'

  # Namespace of tilia-uri library
  module Uri
    require 'tilia/uri/version'

    # Resolves relative urls, like a browser would.
    #
    # This function takes a basePath, which itself _may_ also be relative, and
    # then applies the relative path on top of it.
    #
    # @param [String] base_path
    # @param [String] new_path
    # @return [String]
    def self.resolve(base_path, new_path)
      base = parse(base_path)
      delta = parse(new_path)

      pick = lambda do |part|
        if delta[part]
          delta[part]
        elsif base[part]
          base[part]
        end
      end

      # If the new path defines a scheme, it's absolute and we can just return
      # that.
      return build(delta) if delta['scheme']

      new_parts = {}

      new_parts['scheme'] = pick.call('scheme')
      new_parts['host']   = pick.call('host')
      new_parts['port']   = pick.call('port')

      path = ''
      if !delta['path'].blank?
        # If the path starts with a slash
        if delta['path'][0] == '/'
          path = delta['path']
        else
          # Removing last component from base path.
          path = base['path']
          path = path[0...path.rindex('/')] if path.index '/'
          path += '/' + delta['path']
        end
      else
        path = base['path'].blank? ? '/' : base['path']
      end

      # Removing .. and .
      path_parts = path.split(%r{/})
      if path_parts.empty? # RUBY
        path_parts = (path + ' ').split(%r{/})
        path_parts[-1] = ''
      elsif path[-1] == '/'
        path_parts << ''
      end
      new_path_parts = []

      path_parts.each do |path_part|
        case path_part
        when '.'
          # noop
        when '..'
          new_path_parts.pop
        else
          new_path_parts << path_part
        end
      end

      path = new_path_parts.join '/'

      # If the source url ended with a /, we want to preserve that.
      new_parts['path'] = path
      if delta['query']
        new_parts['query'] = delta['query']
      elsif !base['query'].blank? && delta['host'].blank? && delta['path'].blank?
        # Keep the old query if host and path didn't change
        new_parts['query'] = base['query']
      end

      new_parts['fragment'] = delta['fragment'] if delta['fragment']
      build(new_parts)
    end

    # Takes a URI or partial URI as its argument, and normalizes it.
    #
    # After normalizing a URI, you can safely compare it to other URIs.
    # This function will for instance convert a %7E into a tilde, according to
    # rfc3986.
    #
    # It will also change a %3a into a %3A.
    #
    # @param [String] uri
    # @return [String]
    def self.normalize(uri)
      parts = parse(uri)

      unless parts['path'].blank?
        path_parts = parts['path'].gsub(%r{^/+}, '').split(%r{/})

        new_path_parts = []
        path_parts.each do |path_part|
          case path_part
          when '.'
            # skip
          when '..'
            # One level up in the hierarchy
            new_path_parts.pop
          else
            # Ensuring that everything is correctly percent-encoded.
            new_path_parts << URI.escape(URI.unescape(path_part), Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          end
        end
        parts['path'] = '/' + new_path_parts.join('/')
      end

      if parts['scheme']
        parts['scheme'] = parts['scheme'].downcase
        default_ports = {
          'http'  => '80',
          'https' => '443'
        }

        if !parts['port'].blank? && default_ports.key?(parts['scheme']) && default_ports[parts['scheme']] == parts['port']
          # Removing default ports.
          parts['port'] = nil
        end

        # A few HTTP specific rules.
        case parts['scheme']
        when 'http', 'https'
          if parts['path'].blank?
            # An empty path is equivalent to / in http.
            parts['path'] = '/'
          end
        end
      end

      parts['host'] = parts['host'].downcase if parts['host']

      build(parts)
    end

    # Parses a URI and returns its individual components.
    #
    # This method largely behaves the same as PHP's parse_url, except that it will
    # return an array with all the array keys, including the ones that are not
    # set by parse_url, which makes it a bit easier to work with.
    #
    # @param [String] uri
    # @return [Hash]
    def self.parse(uri)
      u = ::URI.split(uri)
      {
        'scheme'   => u[0],
        'user'     => u[1],
        'host'     => u[2],
        'port'     => u[3],
        'path'     => u[5] || u[6], # 6 = mailto, opaque
        'query'    => u[7],
        'fragment' => u[8]
      }
    end

    # This function takes the components returned from PHP's parse_url, and uses
    # it to generate a new uri.
    #
    # @param [Hash] parts
    # @return [String]
    def self.build(parts)
      uri = ''

      authority = ''
      unless parts['host'].blank?
        authority = parts['host']

        authority = parts['user'] + '@' + authority unless parts['user'].blank?
        authority = authority + ':' + parts['port'].to_s unless parts['port'].blank?
      end

      unless parts['scheme'].blank?
        # If there's a scheme, there's also a host.
        uri = parts['scheme'] + ':'
      end

      unless authority.blank?
        # No scheme, but there is a host.
        uri += '//' + authority
      end

      uri += parts['path'] unless parts['path'].blank?
      uri += '?' + parts['query'] unless parts['query'].blank?
      uri += '#' + parts['fragment'] unless parts['fragment'].blank?

      uri
    end

    # Returns the 'dirname' and 'basename' for a path.
    #
    # The reason there is a custom function for this purpose, is because
    # basename() is locale aware (behaviour changes if C locale or a UTF-8 locale
    # is used) and we need a method that just operates on UTF-8 characters.
    #
    # In addition basename and dirname are platform aware, and will treat
    # backslash (\) as a directory separator on windows.
    #
    # This method returns the 2 components as an array.
    #
    # If there is no dirname, it will return an empty string. Any / appearing at
    # the end of the string is stripped off.
    #
    # @param [String] path
    # @return [Array]
    def self.split(path)
      if path =~ %r{^(?:(?:(.*)(?:\/+))?([^\/]+))(?:\/?)$}u
        [Regexp.last_match[1] || '', Regexp.last_match[2] || '']
      else
        [nil, nil]
      end
    end
  end
end
