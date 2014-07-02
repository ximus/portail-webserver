require 'socket'

class Gate
  include Singleton
  STATUS_ID   = 0x0a
  POSITION_ID = 0x0a
  OPEN_ID     = 0x0b

  delegate :synchronize, to: :@mutex

  def initialize
    @mutex = Mutex.new
    @socket = TCPSocket.open('localhost', 8785)
    parser = Wizzicom::Parser.new

    parser.on_packet do |message|
      puts "Got from parser: #{message}"
    end

    Thread.abort_on_exception=true

    Thread.new do
      # TODO: should be more efficient to grab more than one byte if there is more available
      while line = @socket.getbyte
        puts "Poll receive: #{line.chr}"
        parser << line
      end
      puts "Polling End"
    end
  end

  # TODO: properly handle concurrent access
  def open!
    send(id: OPEN_ID)
  end

  def status
    send(id: STATUS_ID)
  end

  def postition
    send(id: POSITION_ID)
  end

  def send(message)
    synchronize do
      @socket << Wizzicom::Writer.dump(message)
    end
  end
end