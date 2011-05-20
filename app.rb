require 'rubygems'
require 'bundler/setup'

require 'erb'
require 'sinatra'
require 'json'
#require 'haml'
require 'pp'
require 'em-http-request'

require 'settings.rb'

=begin
DEFAULT_LOOKING = {
  :scratch => {:width => 482, :x => 100, :y => 100},
  :ustream_toyota => {:}
}
=end
USTREAMS = ['scratch-day-2011-in-tokyo', 'world-museum-project']
DEFAULT_LOOKING = {
  "scratch" => {"x" => "10", "y" => "10", "width" => "200"},
  "ustream_tokyo" => {"x" => "600", "y" => "10", "width" => "300"},
  "ustream_toyota" => {"x" => "600", "y" => "300", "width" => "300"}
}

set :sessions, true

helpers do
  # 幅から高さを返す
=begin
  def scratch_height(width)
    return (width * 0.8029).round
  end

  def ustream_height(width)
    return (width * 3 / 4).round
  end
=end
  def height(width)
    return (width.to_i * 3 / 4).round.to_s
  end
end

get '/' do
  if session[:settings]
    p 'exsist session'
    @settings = JSON[session[:settings]]
  else
    p 'no session'
    @settings = DEFAULT_LOOKING
  end

  @embeds = {}
  EventMachine.run {
    url = 'http://api.ustream.tv/json/channel/scratch-day-2011-in-tokyo/getCustomEmbedTag'
    params = {:key => 'C547BE0A1478B171798E5B242C71A700', :params => "autoplay:true;mute:true;height:#{height(@settings['ustream_tokyo']['width'])};width:#{@settings['ustream_tokyo']['width']}"}
    http = EventMachine::HttpRequest.new(url).get(:query => params)
    http.errback { p 'Uh oh'; EM.stop }
    http.callback {
      #p http.response_header.status
      #p http.response_header
      p http.response
      @embeds['ustream_tokyo'] = JSON[http.response]['results']
      EventMachine.stop
    }
  }
  EventMachine.run {
    url = 'http://api.ustream.tv/json/channel/world-museum-project/getCustomEmbedTag'
    params = {:key => 'C547BE0A1478B171798E5B242C71A700', :params => "autoplay:true;mute:true;height:#{height(@settings['ustream_toyota']['width'])};width:#{@settings['ustream_toyota']['width']}"}
    http = EventMachine::HttpRequest.new(url).get(:query => params)
    http.errback { p 'Uh oh'; EM.stop }
    http.callback {
      #p http.response_header.status
      #p http.response_header
      p http.response
      @embeds['ustream_toyota'] = JSON[http.response]['results']
      EventMachine.stop
    }
  }
  p @embeds
  @websock_port = WEBSOCK_PORT
  @websock_domain = WEBSOCK_DOMAIN
  erb :index, :layout => false
end

=begin
get '/websock' do
  erb :websock
end

get '/scratch' do
  erb :scratch
end
=end

get '/settings' do
  if session[:settings]
    p 'exsist session'
    @settings = JSON[session[:settings]]
  else
    p 'no session'
    @settings = DEFAULT_LOOKING
  end
  p @settings
  erb :settings
end

post '/settings' do
  pp params.to_hash
  session[:settings] = JSON[params.to_hash]
  redirect '/settings'
end
