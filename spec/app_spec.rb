require_relative 'spec_helper'

describe 'app' do
  let(:data)  {{"full_name" => "henry brown", "email" => 'brama@mail.com', "password" => "S1n4tra"}.to_json}
  let(:data_without_name) {{"email" => 'ben@mail.com', "password" => "hour-123"}.to_json}
  let(:data_without_email) {{"full_name" => "henry brown", "password" => 'happy#11'}.to_json}
  let(:data_without_password) {{"full_name" => "henry brown", "email" => 'happy@mail.com'}.to_json}
  let(:usr_token) {"1XwlP-aoe7uLUp8C-AVke9e4hrdvW8YwBTYqrstCpvSPnnkz1Hl9ebClyG9QMygC8_c760ZwWES9iXXY-ymTuQ"}

  it 'should create account with complete data' do
    post('/users', data, {'CONTENT_TYPE' => 'application/json'})
    last_response.must_be :ok?
    last_response.body.must_include 'henry brown'
    User.first(:email => 'brama@mail.com').destroy
  end

  it 'should not create account without full name' do
    post('/users', data_without_name, {'CONTENT_TYPE' => 'application/json'})
    last_response.status.must_equal 403
    last_response.body.must_include 'Full Name should not be empty'
  end

  it 'should not create account without email' do
    post('/users', data_without_email, {'CONTENT_TYPE' => 'application/json'})
    last_response.status.must_equal 403
    last_response.body.must_include 'Email should not be empty'
  end

  it 'should not create account without password' do
    post('/users', data_without_password, {'CONTENT_TYPE' => 'application/json'})
    last_response.status.must_equal 403
    last_response.body.must_include 'Password should not be empty'
  end

  it 'should not create account with existent email' do
    post('/users', {"full_name" => "henry brown", "email" => 'bravo@mail.com', "password" => "S1n4tra"}.to_json, {'CONTENT_TYPE' => 'application/json'})
    last_response.status.must_equal 403
    last_response.body.must_include 'Email is already taken'
  end

  it 'should generate user token when account is created' do
    post('/users', data, {'CONTENT_TYPE' => 'application/json'})
    last_response.must_be :ok?
    last_response.body.must_include 'henry brown'
    last_response.header.must_include 'X-Access-Token'
    User.first(:email => 'brama@mail.com').destroy
  end

end
