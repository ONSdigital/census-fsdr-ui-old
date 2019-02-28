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

set :census_hrhub_host,      ENV['CENSUS_HRHUB_SERVICE_HOST']
set :census_hrhub_port,      ENV['CENSUS_HRHUB_SERVICE_PORT']
# set :security_user_name,     ENV['security_user_name']
# set :security_user_password, ENV['security_user_password']
# set :protocol,               ENV['CENSUS_HRHUB_PROTOCOL']

# Set global pagination options.
WillPaginate.per_page = 20

# View helper for defining blocks inside views for rendering in templates.
helpers Sinatra::ContentFor2
helpers do

  # View helper for parsing and displaying JSON error responses.
  # def error_flash(message, response)
  #   error = JSON.parse(response)
  #   if error['error']['timestamp']
  #     flash[:error] = "#{message}: #{error['error']['message']}<br>Please quote reference #{error['error']['timestamp']} when contacting support."
  #   elsif error['timestamp']
  #     flash[:error] = "#{message}: #{error['message']}<br>Please quote reference #{error['timestamp']} when contacting support."
  #   end
  # end

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
                                #url: "http://#{settings.census_hrhub_host}:#{settings.census_hrhub_port}/fieldforce/"
                                url: "http://localhost:9290/fieldforce"
                            ) do |fieldforce_response, _request, _result, &_block|
    fieldforce = JSON.parse(fieldforce_response) unless fieldforce_response.code == 404

    puts fieldforce

    erb :field_force, locals: { title: 'Field Force',
                              fieldforce: fieldforce }
  end
end

# Get Field Worker Details
get '/fieldforce/:fieldworkerid' do |fieldworkerid|

  RestClient::Request.execute(method: :get,
                              #url: "http://#{settings.census_hrhub_host}:#{settings.census_hrhub_port}/fieldforce/"
                              url: "http://localhost:9290/fieldforce/#{fieldworkerid}"
                          ) do |fieldworker_response, _request, _result, &_block|
  fieldworker = JSON.parse(fieldworker_response) unless fieldworker_response.code == 404

  erb :field_worker, locals: { title: 'Field Worker',
                            fieldworker: fieldworker }
  end
end
