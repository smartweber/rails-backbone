class AddNotificationSubscriptionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notification_subscription, :boolean, default: false
  end
end
