require "namespaced_logger"

class AppLogger < Logger
  def namespaced(namespace)
    NamespacedLogger.new(namespace, self)
  end
end
