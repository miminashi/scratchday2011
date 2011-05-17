require 'erb'
require 'rubygems'
require 'sinatra'
require 'haml'

get '/' do
  haml :index
end

get '/websock' do
  erb :websock
end

