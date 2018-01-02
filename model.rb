require 'data_mapper'
require 'dm-migrations'
require 'dm-sqlite-adapter'
require 'securerandom'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.sqlite3")

class User
	include DataMapper::Resource
	has n, :contracts

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

class Contract
	include DataMapper::Resource
	belongs_to :user

	property :id, Serial
	property :vendor, String, :required => true, :messages => {:presence => "Vendor should not be empty"}
	property :starts_on, Date, :required => true, :messages => {:presence => "Starts on should not be empty"}
	property :ends_on, Date, :required => true, :messages => {:presence => "Ends on should not be empty" }
	property :price, Float


end

DataMapper.finalize.auto_upgrade!
