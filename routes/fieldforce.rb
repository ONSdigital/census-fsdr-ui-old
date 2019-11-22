
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
get '/fieldforce/view/:viewtype' do |viewtype|
  authenticate!
  erb :index, locals: { title: 'Home' }
  fieldforce = []
  RestClient::Request.execute(method: :get,
                              user: SPRING_SECURITY_USER_NAME,
                              password: SPRING_SECURITY_USER_PASSWORD,
                              url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/fieldforce/byType/#{viewtype}") do |fieldforce_response, _request, _result, &_block|
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
  field_worker_details = []
  field_worker_devices = []
  field_worker_phone_device = []
  field_worker_job_roles = []
  role = session[:role]

  RestClient::Request.execute(method: :get,
                              user: SPRING_SECURITY_USER_NAME,
                              password: SPRING_SECURITY_USER_PASSWORD,
                              url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/fieldforce/byId/#{role}/#{fieldworkerid}") do |field_worker_details_response, _request, _result, &_block|
    unless field_worker_details_response.empty?
      field_worker_details = JSON.parse(field_worker_details_response) unless field_worker_details_response.code == 404
    end
  end

  RestClient::Request.execute(method: :get,
                              user: SPRING_SECURITY_USER_NAME,
                              password: SPRING_SECURITY_USER_PASSWORD,
                              url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/devices/byEmployee/#{fieldworkerid}") do |field_worker_devices_response, _request, _result, &_block|
    unless field_worker_devices_response.empty?
      field_worker_devices = JSON.parse(field_worker_devices_response) unless field_worker_devices_response.code == 404
    end
  end

  if field_worker_devices.any?
    field_worker_devices_html = Json2htmltable.create_table(field_worker_devices)
  end

  RestClient::Request.execute(method: :get,
                              user: SPRING_SECURITY_USER_NAME,
                              password: SPRING_SECURITY_USER_PASSWORD,
                              url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/jobRoles/currentRole/byEmployee/#{fieldworkerid}") do |field_worker_job_roles_response, _request, _result, &_block|
    unless field_worker_job_roles_response.empty?
      field_worker_job_roles = JSON.parse(field_worker_job_roles_response) unless field_worker_job_roles_response.code == 404
    end
  end

  RestClient::Request.execute(method: :get,
                              user: SPRING_SECURITY_USER_NAME,
                              password: SPRING_SECURITY_USER_PASSWORD,
                              url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/devices/byEmployee/getPhoneDevice/#{fieldworkerid}") do |field_worker_phone_device_response, _request, _result, &_block|
    unless field_worker_phone_device_response.empty?
      field_worker_phone_device = JSON.parse(field_worker_phone_device_response) unless field_worker_phone_device_response.code == 404
    end
  end

  field_worker_erb = 'fieldworkerdetails/field_worker_' + role

  erb :"#{field_worker_erb}", layout: :sidebar_layout, locals: { title:'Worker Details',
                                                                 field_worker_details: field_worker_details,
                                                                 field_worker_job_roles: field_worker_job_roles,
                                                                 field_worker_devices: field_worker_devices_html,
                                                                 field_worker_phone_device: field_worker_phone_device}

end

# Get Individual Field Worker History Details
get '/fieldforce/historyById/:fieldworkerid' do |fieldworkerid|
  authenticate!
  field_worker_job_roles_history = []
  field_worker_history = []
  role = session[:role]

  RestClient::Request.execute(method: :get,
                              user: SPRING_SECURITY_USER_NAME,
                              password: SPRING_SECURITY_USER_PASSWORD,
                              url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/fieldforce/historyById/#{role}/#{fieldworkerid}") do |field_worker_history_response, _request, _result, &_block|
    unless field_worker_history_response.empty?
      field_worker_history = JSON.parse(field_worker_history_response) unless field_worker_history_response.code == 404
    end
  end

  RestClient::Request.execute(method: :get,
                              user: SPRING_SECURITY_USER_NAME,
                              password: SPRING_SECURITY_USER_PASSWORD,
                              url: 'http://' + CENSUS_FSDR_HOST + ':' + CENSUS_FSDR_PORT + "/jobRoles/historyById/#{fieldworkerid}") do |field_worker_job_roles_response, _request, _result, &_block|
    unless field_worker_job_roles_response.empty?
      field_worker_job_roles_history = JSON.parse(field_worker_job_roles_response) unless field_worker_job_roles_response.code == 404
    end
  end

  field_worker_history_erb = 'fieldworkerhistory/field_worker_history_' + role

  erb :"#{field_worker_history_erb}", layout: :sidebar_layout, locals: { title: 'Field Worker History',
                                                                 field_worker_history_table: field_worker_history,
                                                                 field_worker_job_roles_history: field_worker_job_roles_history}
end
