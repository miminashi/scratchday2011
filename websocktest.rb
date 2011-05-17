require 'rubygems'
require 'em-websocket'

EventMachine.run {
  EventMachine::WebSocket.start(:host => 'localhost', :port => 8080) do |ws|
    ws.onopen {
      puts 'WebSocket connection open'
      ws.send 'Hello,Client'
    }
    ws.onclose {
      puts 'connection closed'
    }
    ws.onmessage {|msg|
      puts puts "Recieve mesage: #{msg}"
      ws.send "Pong: #{msg}"
    }
  end
  p 'hogehoge'
}
