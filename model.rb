require 'data_mapper'
require 'dm-migrations'
require 'dm-sqlite-adapter'
require 'securerandom'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.sqlite3")

class User
	include DataMapper::Resource
	property :id, Serial
	property :email, String, :required => true, :unique => true,
	 :messages => {
		 :presence => 'Email should not be empty',
		 :is_unique => 'Email is already taken'
	 }
	property :full_name, String, :required => true, :messages => {:presence => "Full Name should not be empty"}
	property :password, String, :required => true, :messages => {:presence => "Password should not be empty"}
	property :token, String, :default => SecureRandom.urlsafe_base64(64), :length => 86

end

DataMapper.finalize.auto_upgrade!
