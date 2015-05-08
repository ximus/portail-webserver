require 'delegate'

class NamespacedLogger < SimpleDelegator
  def initialize(namespace, logger)
    super(logger)
    @namespace = ''
    Array.wrap(namespace).each do |part|
      @namespace << "[#{part.to_s}] "
    end
  end

  Logger::Severity.constants.each do |severity|
    severity = severity.downcase
    define_method(severity) do |msg|
      super(@namespace + msg.to_s)
    end
  end
end
