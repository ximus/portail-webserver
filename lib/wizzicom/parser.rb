require 'thread'

module Wizzicom
  # Wizzilink packet:
  # 2 bytes sync word
  # 1 byte payload size (does not include the 5 bytes from this header)
  # 1 byte sequence number
  # 1 byte packet type identifier
  # N byte payload
  # -------------------------------------------------------------------------------------------
  # | sync0 = 0x01 | sync1 = 0x1f | size |  seq  |  id  | pload (0) | ... | ... | pload (N-1) |
  # -------------------------------------------------------------------------------------------

  class Parser
    def initialize
      @input = Queue.new
      reset!
    end

    def on_packet(&block)
      @handler = block

      Thread.abort_on_exception=true
      Thread.new do
        while @chunk = @input.pop
          puts "STATE IS: #{@state}, data: #{@chunk}"
          send(@state)
        end
      end
    end

    def <<(part)
      @input << part
    end

    module States
      def sync0
        if @chunk == SYNC0
          @state = :sync1
        else
          fail!
        end
      end

      def sync1
        if @chunk == SYNC1
          @state = :length
        else
          fail!
        end
      end

      def length
        @length = @chunk
        @state = :sequence
      end

      # Not sure if I need this yet
      def sequence
        # noop
        @state = :id
      end

      # ID is used by wizzilab's wizzicom, ignored in this app
      def id
        # noop
        @state = :body
      end

      def body
        @body << @chunk
        done! if @position >= @length - 1
        @position += 1
      end
    end
    include States

    def done!
      puts "Parser: full packet of length #{@length} received: #{@body}"
      # currently just skip and forget packets if no handler
      @handler && @handler.call(@body)
      reset!
    end

    def fail!
      reset!
      # try current chunk in clean state
      send(:sync0) unless @state == :sync0
    end

    def reset!
      @state    = :sync0
      @length   = 0
      @position = 0
      @body     = ''
    end
  end
end