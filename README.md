tilia/uri
=========

[![Build Status](https://travis-ci.org/tilia/tilia-uri.svg?branch=master)](https://travis-ci.org/tilia/tilia-uri)

**tilia/uri is a port of [sabre/uri](https://github.com/fruux/sabre-uri)**

sabre/uri is a lightweight library that provides several functions for working
with URIs, staying true to the rules of [RFC3986](https://tools.ietf.org/html/rfc3986/).

Partially inspired by [Node.js URL library](http://nodejs.org/api/url.html), and created to solve real
problems in PHP applications. 100% unitested and many tests are based on
examples from RFC3986.

The library provides the following functions:

1. `resolve` to resolve relative urls.
2. `normalize` to aid in comparing urls.
3. `parse`, which works like PHP's [parse_url](http://php.net/manual/en/function.parse-url.php)
4. `build` to do the exact opposite of `parse`.
5. `split` to easily get the 'dirname' and 'basename' of a URL without all the
   problems those two functions have.


Installation
------------

Simply add tilia-uri to your Gemfile and bundle it up:

```ruby
  gem 'tilia-uri', '~> 1.0'
```


Contributing
------------

See [Contributing](CONTRIBUTING.md)


License
-------

tilia-uri is licensed under the terms of the [three-clause BSD-license](LICENSE).
