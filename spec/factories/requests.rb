#require 'faker'

FactoryGirl.define do 

	factory :request do |f|
		f.bibid { 5000000 + Random.rand(100000) }
	end
	
end