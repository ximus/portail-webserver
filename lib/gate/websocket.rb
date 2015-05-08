require 'faye/websocket'
require 'ext/fix_silent_websocket_exceptions'

class Gate
  class Websocket

    def initialize
      @gate = Gate.instance
      @clients = []
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, opts)

        log.debug [:open]

        if @gate.active?
          ws.send(@gate.status)
        end

        add_client(ws)

        ws.on :message do |event|
          msg = MultiJson.load(event.data)
          log.debug [:message, msg]
          receive_message(msg)
        end

        ws.on :close do |event|
          log.debug [:close, event.code, event.reason]
          remove_client(ws)
          ws = nil
        end

        ws.on :error do |event|
          log.debug "websocket error #{event}"
        end

        # Return async Rack response
        ws.rack_response
      else
        # Normal HTTP request
        [426, {}, []]
      end
    end

    def add_client(client)
      @clients << client
      if @clients.count == 1
        log.debug "got a first client, attaching observer"
        @gate.add_observer(self)
      end
    end

    def remove_client(client)
      @clients << client
      if @clients.empty?
        log.debug "have no clients left, removing observer"
        @gate.delete_observer(self)
      end
    end

    def update(gate_status)
      broadcast(MultiJson.dump(gate_status))
    end

    def broadcast(message)
      @clients.each do |client|
        client.send(message)
      end
    end

    def receive_message(msg)
      action = msg[:action] || return
      if action.in?(Gate::ACTIONS)
        @gate.send(action)
      end
    end

    def log
      App.log.namespaced("Gate Webscoket")
    end

    def opts
      @opts ||= { ping: App.config.websocket.ping }
    end
  end
end
