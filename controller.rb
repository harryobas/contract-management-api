post '/users' do
  content_type :json

  params = parse_json_request
  user = User.new(:full_name => params[:full_name], :email => params[:email], :password => params[:password])
  user.password = BCrypt::Password.create(user.password) if user.password
  if user.save
    headers "X-Access-Token" => user.token 
    {:status => "ok", :data => [user.full_name, user.email]}.to_json
  else
    errors = []
    user.errors.each{|err| errors << err.shift}
    halt 403, {:error => errors}.to_json
  end
end
