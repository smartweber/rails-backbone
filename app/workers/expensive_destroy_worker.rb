class ExpensiveDestroyWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(method, *args)
    self.class.send("#{method}", *args)
  end

  def self.expensive_destroy(class_name, object_id)
    object = class_name.constantize.find(object_id)
    object.destroy
  end
end
