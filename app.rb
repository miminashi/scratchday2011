require 'rubygems'
require 'bundler/setup'

require 'erb'
require 'sinatra'
#require 'haml'

require 'settings.rb'

get '/' do
  @websock_port = WEBSOCK_PORT
  @websock_domain = WEBSOCK_DOMAIN
  erb :index
end

get '/websock' do
  erb :websock
end

get '/scratch' do
  erb :scratch
end

