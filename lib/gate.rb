require 'coap'
require 'cbor'
require "observer"

class Gate
  include Observable

  drivers = File.expand_path('../gate/drivers', __FILE__)
  autoload :Fake, drivers + '/fake'
  autoload :Real, drivers + '/real'

  # Gate states
  # unknown basically means laser is offline
  UNKNOWN     = "unknown"
  OPEN        = "open"
  OPENING     = "opening"
  OPEN_PARTLY = "open_partly"
  CLOSED      = "closed"
  CLOSING     = "closing"

  STATE_ID_TO_S = [
    UNKNOWN,
    OPEN,
    OPENING,
    OPEN_PARTLY,
    CLOSED,
    CLOSING
  ]

  ACTIONS = %w(open close)

  def self.instance
    driver = "Gate::#{config.driver.capitalize}".constantize
    @instance ||= new(driver: driver.new)
  end

  def self.config
    App.config.gate
  end

  delegate *ACTIONS, to: :@driver

  def initialize(downtime: 1, driver:)
    @downtime = downtime
    @driver = driver
    @driver.ondata(&method(:on_data))
  end

  def status
    @last_status
  end

  def add_observer(obs)
    super(obs)
    if count_observers == 1
      @driver.active = true
    end
  end

  def delete_observer(obs)
    super(obs)
    if count_observers == 0
      @driver.active = false
    end
  end

  def active?
    count_observers > 0
  end

  private

  def on_data(msg)
    status = load_gate_status(msg)
    if status != @last_status
      @last_status = status
      changed
      notify_observers(status)
    end
  end

  def load_gate_status(from_gate)
    {
      # from int id to string state
      state:    STATE_ID_TO_S[from_gate[:s]],
      # from int out of 100 to float
      position: from_gate[:p].to_f / 100
    }
  end

  def log
    App.log.namespaced(self.class)
  end
end
