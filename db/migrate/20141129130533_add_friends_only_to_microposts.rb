class AddFriendsOnlyToMicroposts < ActiveRecord::Migration
  def change
    add_column :microposts, :friends_only, :boolean, default: false
  end
end
