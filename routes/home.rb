require 'sinatra'
require 'sinatra/content_for2'
require 'sinatra/flash'
require 'syslog/logger'
require 'will_paginate'
require 'will_paginate/array'
require 'rest_client'
require 'json'
require 'yaml'
require 'open-uri'
require 'sinatra/formkeeper'
require 'csv'

require_relative '../lib/authentication'
require_relative '../lib/core_ext/object'

PROGRAM = 'fsdr'.freeze

CENSUS_FSDR_HOST              = ENV['CENSUS_FSDR_SERVICE_HOST'] || 'localhost'
CENSUS_FSDR_PORT              = ENV['CENSUS_FSDR_SERVICE_PORT'] || '5678'
SPRING_SECURITY_USER_NAME     = ENV['SPRING_SECURITY_USER_NAME'] || 'user'
SPRING_SECURITY_USER_PASSWORD = ENV['SPRING_SECURITY_USER_PASSWORD'] || 'pass'

# Set global pagination options.
WillPaginate.per_page = 20

enable :sessions

# View helper for defining blocks inside views for rendering in templates.
helpers Sinatra::ContentFor2
helpers do

  # View helper for parsing and displaying JSON error responses.
  def error_flash(message, response)
    error = JSON.parse(response)
    if error['error']['timestamp']
      flash[:error] = "#{message}: #{error['error']['message']}<br>Please quote reference #{error['error']['timestamp']} when contacting support."
    elsif error['timestamp']
      flash[:error] = "#{message}: #{error['message']}<br>Please quote reference #{error['timestamp']} when contacting support."
    end
  end

  def error_flash_text(message, response)
    flash[:error] = "#{message}: #{response}"
  end

  # View helper for escaping HTML output.
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

SESSION_EXPIRATION_PERIOD = 60 * 60

# Expire sessions after SESSION_EXPIRATION_PERIOD of inactivity
use Rack::Session::Cookie, key: 'rack.session', path: '/',
                           secret: 'eb46fa947d8411e5996329c9ef0ba35d',
                           expire_after: SESSION_EXPIRATION_PERIOD

helpers Authentication

# Home page.
get '/' do
  authenticate!
  erb :index, locals: { title: 'Home' }
  fieldforce = []
  viewtype = session[:role]
  RestClient::Request.execute(method: :get,
                              user: SPRING_SECURITY_USER_NAME,
                              password: SPRING_SECURITY_USER_PASSWORD,
                              url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/fieldforce/byType/#{viewtype}") do |fieldforce_response, _request, _result, &_block|
    unless fieldforce_response.empty?
      fieldforce = JSON.parse(fieldforce_response) unless fieldforce_response.code == 404
    end

    erb :field_force, locals: { title: 'Field Force view for: ' + viewtype.upcase,
                                fieldforce: fieldforce,
                                viewtype: viewtype }
  end
end

# Search
get '/search' do
  authenticate!
  erb :search, locals: { title: 'Search' }
end

# Download
get '/download' do
  authenticate!
  role = session[:role]

  if role == 'manager'

    RestClient::Request.execute(method: :get,
                                user: SPRING_SECURITY_USER_NAME,
                                password: SPRING_SECURITY_USER_PASSWORD,
                                url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + '/fieldforce/allEmployeeCsv') do |download_file, _request, _result, &_block|
      doc = 'data.csv'
      File.open(doc, 'w') do |download|
        download.puts download_file
      end
      send_file doc, type: 'text; charset=utf-8', disposition: 'attachment'
    end
    redirect request.referrer
  else
    flash[:notice] = 'You do not have permissions to download CSV?'
    redirect '/'
  end

end

# Search Results
post '/searchresults' do
  authenticate!
  results         = []
  first_name      = params[:firstname]
  surname         = params[:surname]
  job_role_id     = params[:jobroleid]
  area_code       = params[:areacode]
  id_badge_number = params[:idbadgenumber]

  multi_query_flag = false
  search_params = 'employeeSearch?'
  unless surname.empty?
    search_params += '&' if multi_query_flag
    search_params = search_params + 'surname=' + surname
    multi_query_flag = true
  end

  unless first_name.empty?
    search_params += '&' if multi_query_flag
    search_params = search_params + 'firstName=' + first_name
    multi_query_flag = true
  end

  unless job_role_id.empty?
    search_params += '&' if multi_query_flag
    search_params = search_params + 'jobRoleId=' + job_role_id
    multi_query_flag = true
  end

  unless area_code.empty?
    search_params += '&' if multi_query_flag
    search_params = search_params + 'areaCode=' + area_code
    multi_query_flag = true
  end

  unless id_badge_number.empty?
    search_params += '&' if multi_query_flag
    search_params = search_params + 'idBadgeNo=' + id_badge_number
    multi_query_flag = true
  end
  RestClient::Request.execute(method: :get,
                              user: SPRING_SECURITY_USER_NAME,
                              password: SPRING_SECURITY_USER_PASSWORD,
                              url: "http://#{CENSUS_FSDR_HOST}:#{CENSUS_FSDR_PORT}/fieldforce/#{search_params}") do |fieldforce_response, _request, _result, &_block|
    results = JSON.parse(fieldforce_response) unless fieldforce_response.code == 404
    erb :searchresults, locals: { title: 'Search Results',
                                  results: results }
  end
end
