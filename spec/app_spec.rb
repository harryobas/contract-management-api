require_relative 'spec_helper'

describe 'app' do
  let(:data)  {{"full_name" => "henry brown", "email" => 'brama@mail.com', "password" => "S1n4tra"}.to_json}
  let(:data_without_name) {{"email" => 'ben@mail.com', "password" => "hour-123"}.to_json}
  let(:data_without_email) {{"full_name" => "henry brown", "password" => 'happy#11'}.to_json}
  let(:data_without_password) {{"full_name" => "henry brown", "email" => 'happy@mail.com'}.to_json}
  let(:usr_token) {"1XwlP-aoe7uLUp8C-AVke9e4hrdvW8YwBTYqrstCpvSPnnkz1Hl9ebClyG9QMygC8_c760ZwWES9iXXY-ymTuQ"}
  let(:user_token) {"jpqmfqTft2u9vqVnkTbm98kLMlhvB5OKFaGVrQzp7W9h7-X9FIVSyHIYrDh1pK6Mj2t--vidF8hdNgV7CXSQGA"}

  let(:contract_data) {{"vendor" => "vodafone", "starts_on" => "10/10/2013", "ends_on" => "10/10/2014", "price" => "45.59"}.to_json}
  let(:contract_data_with_empty_vendor) {{"starts_on" => "10/10/2013", "ends_on" => "10/10/2014", "price" => "45.59"}.to_json}
  let(:contract_data_with_empty_starts_on) {{"vendor" => "vodafone", "ends_on" => "10/10/2014", "price" => "45.59"}.to_json}
  let(:contract_data_with_empty_ends_on) {{"vendor" => "vodafone", "starts_on" => '10/10/2013', "price" => "45.59"}.to_json}
  let(:contract_data_with_ends_on_less_than_starts_on) {{"vendor" => "vodafone", "starts_on" => '10/10/2014', "ends_on" => '10/10/2013', "price" => "45.59"}.to_json}


  it 'should create account with valid data' do
    post('/users', data, {'CONTENT_TYPE' => 'application/json'})
    last_response.status.must_equal 201 
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

  it 'should get contract with a specified id' do
    get('/contracts/179', {}, {'X-Access-Token' => usr_token})
    last_response.status.must_equal 200
    json = {id: 179, vendor: 'vodafone', starts_on: '2013-10-10', ends_on: '2014-10-10', price: 45.59, user_id: 53}
    json.to_json.must_equal last_response.body

  end

  it 'should not get contract which is not owned by user making the request' do
    get('/contracts/177', {}, {'X-Access-Token' => user_token})
    last_response.status.must_equal 404
    json = {status: 404, reason: "Contract not found"}
    json.to_json.must_equal last_response.body

  end

end
