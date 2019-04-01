require_relative '../lib/core_ext/nilclass'
require_relative '../lib/core_ext/string'
require_relative '../lib/core_ext/object'

logger = Syslog::Logger.new(PROGRAM, Syslog::LOG_USER)

helpers do
  def url_format(str)
    str.gsub(/\s+/, '').downcase
  end
end

# Data page.
get '/fieldforce/view/:viewtype' do | viewtype |
  authenticate!
  erb :index, locals: { title: 'Home' }
  fieldforce = []
  RestClient::Request.execute(method: :get,
                              url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/fieldforce/#{viewtype}") do |fieldforce_response, _request, _result, &_block|
    unless fieldforce_response.empty?
      fieldforce = JSON.parse(fieldforce_response) unless fieldforce_response.code == 404
    end

    erb :field_force, layout: :sidebar_layout, locals: { title: 'Field Force view for: ' + viewtype.upcase,
                                fieldforce: fieldforce,
                                viewtype: viewtype }
  end
end

# Get Individual Field Worker Details
get '/fieldforce/:fieldworkerid' do |fieldworkerid|
  authenticate!
  fieldworker = []
  fieldworkerhistory = []
  RestClient::Request.execute(method: :get,
                              url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/fieldforce/byId/#{fieldworkerid}") do |fieldworker_response, _request, _result, &_block|
    unless fieldworker_response.empty?
      fieldworker = JSON.parse(fieldworker_response) unless fieldworker_response.code == 404
    end

    RestClient::Request.execute(method: :get,
                                url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/fieldforce/byId/#{fieldworkerid}") do |fieldworkerhistory_response, _request, _result, &_block|
      unless fieldworkerhistory_response.empty?
        fieldworkerhistory = JSON.parse(fieldworker_response) unless fieldworkerhistory_response.code == 404
      end

    erb :field_worker, layout: :sidebar_layout, locals: { title: 'Field Worker',
                                 fieldworker: fieldworker,
                                  fieldworkerhistory: fieldworkerhistory }
    end
  end
end
