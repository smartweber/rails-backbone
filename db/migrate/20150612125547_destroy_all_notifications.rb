class DestroyAllNotifications < ActiveRecord::Migration
  def up
    Notification.destroy_all
  end
end
