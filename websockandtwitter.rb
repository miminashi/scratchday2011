require 'rubygems'
require "bundler/setup"

require 'pp'
require 'em-websocket'
require 'em-http-request'
require 'json'
require 'bitly'

require 'settings'

# CONSTANTS
STREAMING_URL = 'http://stream.twitter.com/1/statuses/filter.json'
#STREAMING_URL = 'http://stream.twitter.com/1/statuses/sample.json'

SCRATCH_URL_REGEXP = /http\:\/\/scratch\.mit\.edu\/projects\/.+\/\d+/
BITLY_URL_REGEXP = /http:\/\/bit\.ly\/.+/

# LIBRALY SETTIGNS
Bitly.use_api_version_3


$sockets = []

# ScratchプロジェクトのURLを含むならプロジェクトのURLを
# 含まなければnilを返す
def scratch_project_urls(tweet)
  urls = nil
  tweet["entities"]["urls"].each do |u|
    url = u['url']
    if url =~ SCRATCH_URL_REGEXP
      if urls == nil
        urls = []
      end
      urls << url 
    elsif url =~ BITLY_URL_REGEXP
      if urls == nil
        urls = []
      end
      bitly = Bitly.new(BITLY_USERNAME, BITLY_APIKEY)
      bitly_hash = url.gsub(/http:\/\/bit\.ly\//, '')
      expanded_url = bitly.expand(bitly_hash).long_url
      if expanded_url =~ SCRATCH_URL_REGEXP
        urls << expanded_url
      end
    end
  end
  return urls
end

# ScratchプロジェクトのURLからオーナーとidを返す
def get_scratch_project_owner_and_id(url)
  eles = url.split('/')
  id = eles[-1]
  owner = eles[-2]
  return owner, id
end

def handle_tweet(tweet)
  #return unless tweet['text']
  pp tweet
  if tweet['text']
=begin
    if tweet['text'] =~ SCRATCH_URL_REGEXP
      puts 'SCRATCH ' + $&
    elsif tweet['text'] =~ BITLY_URL_REGEXP
      puts 'BITLY ' + $&
      bitly = Bitly.new(BITLY_USERNAME, BITLY_APIKEY)
      shortenurl = $&
      bitly_hash = shortenurl.gsub(/http:\/\/bit\.ly\//, '')
      puts 'SCRATCH' + bitly.expand(bitly_hash).long_url 
    end
=end
    send_data = {:id => tweet['id'], :text => tweet['text'], :profile_image_url => tweet['user']['profile_image_url']}
    if urls = scratch_project_urls(tweet)
      owner, id = get_scratch_project_owner_and_id(urls[0]);
      send_data['scratch_project'] = {:owner => owner, :id => id}
    end

    $sockets.each do |ws|
      #pp tweet
      ws.send JSON[send_data]
    end
  end
  puts tweet['text']
end

EventMachine.run {
  EventMachine::WebSocket.start(:host => 'sns.hiroba.sist.chukyo-u.ac.jp', :port => 8088) do |ws|
    ws.onopen {
      puts 'WebSocket connection open'
      ws.send 'Hello,Client'
    }
    ws.onclose {
=begin
      $sockets.each do |socket|
        if socket == ws
          p true
        else
          p false
        end
      end
=end
      $sockets.reject! do |socket|
        socket == ws
      end
      puts "sockets: #{$sockets.size}"
      puts 'connection closed'
    }
    ws.onmessage {|msg|
      puts puts "Recieve mesage: #{msg}"
      ws.send "Pong: #{msg}"
    }
    $sockets << ws
    pp $sockets
  end
  p 'websock'

  http = EM::HttpRequest.new(STREAMING_URL).post(
    :head => {'Authorization' => [USERNAME, PASSWORD]}, 
    #:body => {:track => '#scratchday'}, 
    :body => {:track => HASHTAGS.map{|ele| '#' + ele}.join(',')}, 
    :timeout => 0
  )
  buffer = ""
  http.stream do |chunk|
    #p chunk
    buffer += chunk
    while line = buffer.slice!(/.+\r?\n/)
      begin
        handle_tweet JSON.parse(line)
      rescue
        next
      end
    end
  end
  http.callback do
    puts "!!!!!!!!!!!!!!!!!!!!!!CALLBACK!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  end
  p 'streaming'
}
