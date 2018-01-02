

post '/users' do

  params = parse_json_request

  user = User.new

  user.full_name = params[:full_name] if params.key?(:full_name)
  user.email = params[:email] if params.key?(:email)
  user.password = hash_password(params[:password]) if params.key?(:password)

  if user.save
    status 200
    {id: user.id, full_name: user.full_name, email: user.email, token: user.token}.to_json
  else
    status 400
    json_status 400, user.errors.to_hash
  end
end

post '/contracts' do
  authenticate!
  user = User.first(:token => @user_token) if @user_token
  params = parse_json_request

  contract = Contract.new

  contract.vendor = params[:vendor] if params.key?(:vendor)
  contract.starts_on = parse_date_string(params[:starts_on]) if params.key?(:starts_on)
  contract.ends_on = parse_date_string(params[:ends_on]) if params.key?(:ends_on)
  contract.price = Float(params[:price]) if params.key?(:price)

  user.contracts << contract

  if contract.save and user.save
    if contract.ends_on < contract.starts_on
      contract.destroy
      halt 400, json_status(400, "Ends on should be greater than Starts on")
    end
    headers["Location"] = "/contracts/#{contract.id}"
    status 201 #created
    contract.to_json
  else
    status 400
    json_status 400, contract.errors.to_hash
  end

end
