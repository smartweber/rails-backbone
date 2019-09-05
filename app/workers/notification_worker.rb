class NotificationWorker
  include Sidekiq::Worker

  def perform(method, *args)
    Notification.send("#{method}", *args)
  end

  Notification::TYPES.each do |method_name|
    define_singleton_method(method_name.to_sym) do |*args|
      self.perform_async(method_name, *args)
    end
  end
end
