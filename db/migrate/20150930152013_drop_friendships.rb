class DropFriendships < ActiveRecord::Migration
  def change
    Notification.where(notification_type: %w(accepted_friend_request friend_request)).destroy_all
    drop_table :friendships
  end
end
