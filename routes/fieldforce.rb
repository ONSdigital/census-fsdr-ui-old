
require_relative '../lib/core_ext/nilclass'
require_relative '../lib/core_ext/string'
require_relative '../lib/core_ext/object'
require_relative '../lib/json2htmltable'

helpers Json2htmltable

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
  fieldworkerdetails = []
  fieldworkerdevices = []
  fieldworkerjobroles = []
  fieldworkerhistory = []
  role = session[:role]
  RestClient::Request.execute(method: :get,
                              url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/fieldforce/byId/#{role}/#{fieldworkerid}") do |fieldworkerdetails_response, _request, _result, &_block|
    unless fieldworkerdetails_response.empty?
      fieldworkerdetails = JSON.parse(fieldworkerdetails_response) unless fieldworkerdetails_response.code == 404
    end
  end

  RestClient::Request.execute(method: :get,
                              url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/devices/byEmployee/#{fieldworkerid}") do |fieldworkerdevices_response, _request, _result, &_block|
    unless fieldworkerdevices_response.empty?
      fieldworkerdevices = JSON.parse(fieldworkerdevices_response) unless fieldworkerdevices_response.code == 404
    end
  end

  RestClient::Request.execute(method: :get,
                              url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/jobRoles/byEmployee/#{fieldworkerid}") do |fieldworkerjobroles_response, _request, _result, &_block|
    unless fieldworkerjobroles_response.empty?
      fieldworkerjobroles = JSON.parse(fieldworkerjobroles_response) unless fieldworkerjobroles_response.code == 404
    end
  end

  RestClient::Request.execute(method: :get,
                              url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/fieldforce/historyById/#{role}/#{fieldworkerid}") do |fieldworkerhistory_response, _request, _result, &_block|
    unless fieldworkerhistory_response.empty?
      fieldworkerhistory = JSON.parse(fieldworkerhistory_response) unless fieldworkerhistory_response.code == 404
    end
  end

  if fieldworkerdetails.any?
    fieldworkerdetailshtml =  Json2htmltable::create_table(fieldworkerdetails)
  end
  if fieldworkerdevices.any?
    fieldworkerdeviceshtml =  Json2htmltable::create_table(fieldworkerdevices)
  end
  if fieldworkerjobroles.any?
    fieldworkerjobroleshtml =  Json2htmltable::create_table(fieldworkerjobroles)
  end
  if fieldworkerhistory.any?
    fieldworkerhistoryhtml =  Json2htmltable::create_table(fieldworkerhistory)
  end


  erb :field_worker, layout: :sidebar_layout, locals: { title: 'Field Worker',
                                                        fieldworkerdetails: fieldworkerdetailshtml,
                                                        fieldworkerdevices: fieldworkerdeviceshtml,
                                                        fieldworkerjobroles: fieldworkerjobroleshtml,
                                                        fieldworkerhistory: fieldworkerhistoryhtml
                                                      }

end
