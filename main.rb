require 'rubygems'
require 'sinatra'

set :sessions, true

get '/inline' do 
	"Hi,directly from the action ! "
end 

get '/template' do 
	erb :mytemplate, layout: 'layout'
end 

get '/nested_template' do 
	erb :"/user/profile"
end 

get '/nothere' do 
	redirect '/inline'
end

get '/form' do 
	erb :form
end 

post '/myaction'  do 
	puts params['username']
end 

get '/test' do 
	"hi from action "
end

get '/template1' do 
	erb :mytemplate2 
end 

get '/nested_template1' do 
	erb :'user/profile1'
end



















