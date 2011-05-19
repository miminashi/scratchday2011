require 'rubygems'
require "bundler/setup"

require 'erb'
require 'sinatra'
#require 'haml'

get '/' do
  erb :index
end

get '/websock' do
  erb :websock
end

get '/scratch' do
  erb :scratch
end

