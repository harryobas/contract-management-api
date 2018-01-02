
require 'sinatra'
#require 'bundler'
require 'json'
require 'bcrypt'
require 'date'
require_relative './controller'
require_relative './model'
require_relative './helpers'

#Bundler.require(:default)

configure do
	enable :sessions
	set :json_encoder, :to_json
end

before do
	content_type :json
end
