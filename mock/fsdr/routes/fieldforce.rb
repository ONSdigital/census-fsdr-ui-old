# List actions.
get '/fieldforce/:consumer' do |consumer|
  erb :field_force, locals: {}
end

get '/fieldforce/byId/:fieldworkerid' do |fieldworkerid|
  erb :field_worker, locals: { fieldworkerid: fieldworkerid }
end

# search example
get '/fieldforce/surname/:surname' do | surname |
  erb :field_search, locals: {surname: surname}
end

# download file example
get '/fieldforce/file/:consumer' do | consumer |
  erb :field_force, locals: {}
end
