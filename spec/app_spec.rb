require_relative 'spec_helper'

describe 'app' do
  let(:data)  {{"full_name" => "henry brown", "email" => 'brama@mail.com', "password" => "S1n4tra"}.to_json}
  let(:data_without_name) {{"email" => 'ben@mail.com', "password" => "hour-123"}.to_json}
  let(:data_without_email) {{"full_name" => "henry brown", "password" => 'happy#11'}.to_json}
  let(:data_without_password) {{"full_name" => "henry brown", "email" => 'happy@mail.com'}.to_json}
  let(:usr_token) {"1XwlP-aoe7uLUp8C-AVke9e4hrdvW8YwBTYqrstCpvSPnnkz1Hl9ebClyG9QMygC8_c760ZwWES9iXXY-ymTuQ"}

  let(:contract_data) {{"vendor" => "vodafone", "starts_on" => "10/10/2013", "ends_on" => "10/10/2014", "price" => "45.59"}.to_json}
  let(:contract_data_with_empty_vendor) {{"starts_on" => "10/10/2013", "ends_on" => "10/10/2014", "price" => "45.59"}.to_json}
  let(:contract_data_with_empty_starts_on) {{"vendor" => "vodafone", "ends_on" => "10/10/2014", "price" => "45.59"}.to_json}
  let(:contract_data_with_empty_ends_on) {{"vendor" => "vodafone", "starts_on" => '10/10/2013', "price" => "45.59"}.to_json}
  let(:contract_data_with_ends_on_less_than_starts_on) {{"vendor" => "vodafone", "starts_on" => '10/10/2014', "ends_on" => '10/10/2013', "price" => "45.59"}.to_json}


  it 'should create account with valid data' do
    post('/users', data, {'CONTENT_TYPE' => 'application/json'})
    last_response.status.must_equal 200
    last_response.body.must_include 'henry brown'
    last_response.body.must_include 'brama@mail.com'
    User.first(:email => 'brama@mail.com').destroy
  end

  it 'should not create account without full name' do
    post('/users', data_without_name, {'CONTENT_TYPE' => 'application/json'})
    last_response.status.must_equal 400
    last_response.body.must_include 'Full Name should not be empty'
  end

  it 'should not create account without email' do
    post('/users', data_without_email, {'CONTENT_TYPE' => 'application/json'})
    last_response.status.must_equal 400
    last_response.body.must_include 'Email should not be empty'
  end

  it 'should not create account without password' do
    post('/users', data_without_password, {'CONTENT_TYPE' => 'application/json'})
    last_response.status.must_equal 400
    last_response.body.must_include 'Password should not be empty'
  end

  it 'should not create account with existent email' do
    post('/users', {"full_name" => "henry brown", "email" => 'bravo@mail.com', "password" => "S1n4tra"}.to_json,
     {'CONTENT_TYPE' => 'application/json'})
     last_response.status.must_equal 400
     last_response.body.must_include 'Email is already taken'
  end

  it 'should generate user token when account is created' do
    post('/users', data, {'CONTENT_TYPE' => 'application/json'})
    last_response.body.must_include(User.first(:email => 'brama@mail.com').token)
    User.first(:email => 'brama@mail.com').destroy
  end

  it 'should not create contract without authentication' do
    post('/contracts', contract_data, {'CONTENT_TYPE' => 'application/json'})
    last_response.status.must_equal 403
    last_response.body.must_include "Authentication required!"
  end

  it 'should create contract with valid data' do
    post('/contracts', contract_data,
     {'CONTENT_TYPE' => 'application/json', 'X-Access-Token' => usr_token})
     last_response.status.must_equal 201
     last_response.body.must_include "vodafone"
     last_response.body.must_include "45.59"
  end

  it 'should not create contract with empty vendor' do
    post('/contracts', contract_data_with_empty_vendor,
     {'CONTENT_TYPE' => 'application/json', 'X-Access-Token' => usr_token})
     last_response.status.must_equal 400
     last_response.body.must_include "Vendor should not be empty"
  end

  it 'should not create contract with empty starts_on' do
    post('/contracts', contract_data_with_empty_starts_on,
     {'CONTENT_TYPE' => 'application/json', 'X-Access-Token' => usr_token})
     last_response.status.must_equal 400
     last_response.body.must_include "Starts on should not be empty"
  end

  it 'should not create contract with empty ends_on' do
    post('/contracts', contract_data_with_empty_ends_on,
     {'CONTENT_TYPE' => 'application/json', 'X-Access-Token' => usr_token})
     last_response.status.must_equal 400
     last_response.body.must_include "Ends on should not be empty"
  end

  it 'should not create contract with ends_on less than starts_on' do
    post('/contracts', contract_data_with_ends_on_less_than_starts_on,
     {'CONTENT_TYPE' => 'application/json', 'X-Access-Token' => usr_token})
     last_response.status.must_equal 400
     last_response.body.must_include "Ends on should be greater than Starts on"
  end

end
