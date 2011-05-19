require 'erb'
require 'rubygems'
require 'sinatra'
require 'haml'

get '/' do
  erb :index
end

get '/websock' do
  erb :websock
end

get '/scratch' do
  erb :scratch
end

