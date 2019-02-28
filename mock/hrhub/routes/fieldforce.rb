# List actions.
get '/fieldforce' do
  erb :field_force, locals: {}
end

get '/fieldforce/:fieldworkerid' do |fieldworkerid|
    erb :field_worker, locals: {fieldworkerid: fieldworkerid}
end
