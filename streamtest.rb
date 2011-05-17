require 'rubygems'
require 'em-http-request'
require 'json'

STREAMING_URL = 'http://stream.twitter.com/1/statuses/filter.json'
#STREAMING_URL = 'http://stream.twitter.com/1/statuses/sample.json'

username = 'botmmns01'
password = 'botmmns'

def handle_tweet(tweet)
  #return unless tweet['text']
  puts tweet['text']
end

EventMachine.run do
  http = EM::HttpRequest.new(STREAMING_URL).post(
    :head => {'Authorization' => [username, password]}, 
    :body => {:track => '#scratchday'}, 
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
  p 'gehogeho'
end

