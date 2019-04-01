def test_password(password, hash)
  hash == password
end

User = Struct.new(:id, :username, :password_hash, :role)
USERS = [
  User.new(1, 'FSSSUSER', 'password', 'FSSS'),
  User.new(2, 'HRUSER', 'password', 'HR'),
  User.new(3, 'RECRUITUSER', 'password', 'RECR'),
]

auth_logger   = Syslog::Logger.new(PROGRAM, Syslog::LOG_AUTHPRIV)

helpers do
  def user_role
    session[:user].groups.join(',')
  end
end

get '/signin/?' do
  erb :signin, layout: :layout, locals: { title: 'Sign In' }
end

post '/signin/?' do
  user = USERS.find { |u| u.username == params[:username] }
    if user && test_password(params[:password], user.password_hash)
      session.clear
      session[:valid_token] = true
      session[:user] = user.username
      session[:role] = user.role
      puts session[:user]
      puts session
      redirect '/'
    else
      puts "in else"
      flash[:notice] = 'You could not be signed in. Did you enter the correct credentials?'
      redirect '/signin'
    end

end

get '/signout' do
  session.clear
  session[:valid_token] = nil
  redirect '/signin'
end
