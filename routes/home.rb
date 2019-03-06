require 'sinatra'
require 'sinatra/content_for2'
require 'sinatra/flash'
require 'syslog/logger'
require 'will_paginate'
require 'will_paginate/array'
require 'rest_client'
require 'ons-ldap'
require 'json'
require 'yaml'
require 'open-uri'
require 'sinatra/formkeeper'
require 'csv'

require_relative '../lib/core_ext/object'

PROGRAM = 'hrhub'.freeze

CENSUS_HRHUB_HOST = ENV['CENSUS_HRHUB_SERVICE_HOST'] || 'localhost'
CENSUS_HRHUB_PORT = ENV['CENSUS_HRHUB_SERVICE_PORT'] || '5678'

puts (CENSUS_HRHUB_HOST)
# set :security_user_name,     ENV['security_user_name']
# set :security_user_password, ENV['security_user_password']
# set :protocol,               ENV['CENSUS_HRHUB_PROTOCOL']

# Set global pagination options.
WillPaginate.per_page = 20

# View helper for defining blocks inside views for rendering in templates.
helpers Sinatra::ContentFor2
helpers do

  def error_flash_text(message, response)
    flash[:error] = "#{message}: #{response}"
  end

  # View helper for escaping HTML output.
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

# Home page.
get '/' do
  erb :index, locals: { title: 'Home' }
    RestClient::Request.execute(method: :get,
                                url: "http://" + CENSUS_HRHUB_HOST + ":" + CENSUS_HRHUB_PORT + "/fieldforce/fwmt"
                                #url: "http://localhost:5678/fieldforce/fwmt"
                            ) do |fieldforce_response, _request, _result, &_block|
    fieldforce = JSON.parse(fieldforce_response) unless fieldforce_response.code == 404
    puts "http://" + CENSUS_HRHUB_HOST + ":" + CENSUS_HRHUB_PORT + "/fieldforce/"
    puts fieldforce

    erb :field_force, locals: { title: 'Field Force',
                              fieldforce: fieldforce }
  end
end

# Get Field Worker Details
get '/fieldforce/:fieldworkerid' do |fieldworkerid|

  RestClient::Request.execute(method: :get,
                              url: "http://" + CENSUS_HRHUB_HOST + ":" + CENSUS_HRHUB_PORT + "/fieldforce/byId/#{fieldworkerid}"
                              #url: "http://localhost:5678/fieldforce/byId/#{fieldworkerid}"
                          ) do |fieldworker_response, _request, _result, &_block|
  fieldworker = JSON.parse(fieldworker_response) unless fieldworker_response.code == 404
 puts fieldworker
  erb :field_worker, locals: { title: 'Field Worker',
                            fieldworker: fieldworker }
  end
end

# Get Field Worker Details
get '/download' do

  filetype_array = ["fwmt", "lws"]

  erb :download, locals: { title: 'File Download',
                           filetype_array: filetype_array,
                           url: "http://" + CENSUS_HRHUB_HOST + ":" + CENSUS_HRHUB_PORT}
end
