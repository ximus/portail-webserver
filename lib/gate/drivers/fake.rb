class Gate
  class Fake
    INTERVAL = 1 # sec between status updates
    DURATION = 10 # sec for the gate to fully open/close
    MIN = 0
    MAX = 100

    attr_writer :active

    def initialize
      @state = CLOSED
      @pos = 0
      @incr = (MAX - MIN).to_f / (DURATION / INTERVAL)
      @active = false
      Thread.new { loop }
    end

    def ondata(&callback)
      @ondata = callback
    end

    def open
      @state = OPENING
    end

    def close
      @state = CLOSING
    end

    private

    def loop
      while 1
        if @state == CLOSING
          if @pos <= MIN
            @state = CLOSED
            @pos = MIN
          else
            @pos -= @incr
          end
        end
        if @state == OPENING
          if @pos >= MAX
            @state = OPEN
            @pos = MAX
          else
            @pos += @incr
          end
        end
        if @active and @ondata
          @ondata.call({
            s: STATE_ID_TO_S.index(@state),
            p: @pos
          })
        end
        sleep INTERVAL
      end
    end
  end
end
