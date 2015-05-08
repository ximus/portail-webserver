class GateController < Controller

  # GET /ws/gate
  get '/gate' do
    puts "HOHOHOHO*****"
  #   unless Faye::WebSocket.websocket?(request.env)
  #     # security should be better if this behaves at 404,
  #     # hopefully attacker won't check latency
  #     halt 404
  #     return
  #   end

  #   ws = Faye::WebSocket.new(request.env)

  #   ws.on(:open) do |event|
  #     puts 'On Open'
  #   end

  #   # ws.on(:message) do |msg|
  #   #   ws.send(msg.data.reverse)  # Reverse and reply
  #   # end

  #   ws.on(:close) do |event|
  #     puts 'On Close'
  #   end

  #   ws.rack_response
  end
end
