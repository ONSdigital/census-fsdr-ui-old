require 'digest'

CENSUS_FSDR_DBHOST = ENV['DB_HOST'] || 'localhost'
CENSUS_FSDR_DBPORT = ENV['DB_PORT'] || '5432'
CENSUS_FSDR_DBNAME = ENV['DB_NAME'] || 'postgres'
CENSUS_FSDR_DBUSER = ENV['DB_USERNAME'] || 'postgres'
CENSUS_FSDR_DBPASS = ENV['DB_PASSWORD'] || 'postgres'

def test_password(hashed_password, stored_password)
  hashed_password == stored_password
end

auth_logger = Syslog::Logger.new(PROGRAM, Syslog::LOG_AUTHPRIV)

helpers do
  def user_role
    session[:user].groups.join(',')
  end
end

get '/signin/?' do
  erb :signin, layout: :layout, locals: { title: 'Sign In' }
end

post '/signin/?' do

  con = PG.connect host: CENSUS_FSDR_DBHOST, port: CENSUS_FSDR_DBPORT, dbname: CENSUS_FSDR_DBNAME, user: CENSUS_FSDR_DBUSER, password: CENSUS_FSDR_DBPASS
  result = con.exec("select password, user_role from fsdr.user_authentication where username = '#{params[:username]}';")
  user = params[:username]
  hashed_password = Digest::MD5.hexdigest(params[:password]).upcase
  stored_password = result[0]['password']

  if user && test_password(hashed_password, result[0]['password'])
    session.clear
    session[:valid_token] = true
    session[:user] = user
    session[:role] = result[0]['user_role']
    redirect '/'
  else
    flash[:notice] = 'You could not be signed in. Did you enter the correct credentials?'
    redirect '/signin'
  end

end

get '/signout' do
  session.clear
  session[:valid_token] = nil
  redirect '/signin'
end
