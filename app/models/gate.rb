require 'singleton'

class Gate
  include Singleton

  def initialize
    @connection = TCP.new
  end

  def open!
    @connection << "blah"
  end
end