require 'pp'
require 'rubygems'
require 'em-websocket'
require 'em-http-request'
require 'json'

STREAMING_URL = 'http://stream.twitter.com/1/statuses/filter.json'
#STREAMING_URL = 'http://stream.twitter.com/1/statuses/sample.json'

HASHTAGS = ['apple', 'scratchday']
username = 'botmmns01'
password = 'botmmns'

$sockets = []

def handle_tweet(tweet)
  #return unless tweet['text']
  $sockets.each do |ws|
    ws.send tweet['text']
  end
  puts tweet['text']
end


EventMachine.run {
  EventMachine::WebSocket.start(:host => 'localhost', :port => 8080) do |ws|
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
    :head => {'Authorization' => [username, password]}, 
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
  p 'streaming'
}
