module Authentication
  def authenticate!
    unless session[:user] && session[:valid_token] # rubocop:disable Style/GuardClause
      # session[:original_request] = request.path_info
      redirect '/signin'
    end
  end
end
