require 'rubygems'
require 'bundler'

Bundler.require

require_relative 'routes/home'
require_relative 'routes/error'
require_relative 'routes/fieldforce'
require_relative 'routes/authentication'

# require 'rack/etag'
# require 'rack/conditionalget'
# require 'rack/deflater'
#
# use Rack::ETag
# use Rack::ConditionalGet
# use Rack::Deflater

run Sinatra::Application
