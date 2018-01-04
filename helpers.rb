helpers do
  def parse_json_request
    begin
      if request.body.size > 0
        request.body.rewind
        @request_payload = JSON.parse request.body.read, { symbolize_names: true }
      end
    rescue JSON::ParserError => e
      request.body.rewind
      halt 403, json_status(403, "The body #{request.body.read} was not JSON")
    end
  end

  def authenticate!
     #user token for authentication can be received from either the request header or request body
    @user_token = request.env['X-Access-Token'] or parse_json_request[:token]
    halt 403, json_status(403, 'Authentication required!') unless User.all.map{|u| u.token}.include?(@user_token)
  end

  def json_status(code, reason)
    {
      status: code,
      reason: reason
    }.to_json
  end

  def valid_id?(id)
    id && id.to_s =~ /^\d+$/
  end

  def parse_date_string(date)
    Date.strptime(date, '%m/%d/%Y')
  end

  def hash_password(password)
    BCrypt::Password.create(password)
  end

end
