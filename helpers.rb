helpers do
  def parse_json_request
    begin
      if request.body.size > 0
        request.body.rewind
        @request_payload = JSON.parse request.body.read, { symbolize_names: true }
      end
    rescue JSON::ParserError => e
      request.body.rewind
      puts "The body #{request.body.read} was not JSON"
    end
  end

end
