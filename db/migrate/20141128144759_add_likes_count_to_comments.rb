class AddLikesCountToComments < ActiveRecord::Migration
  def change
    add_column :comments, :likes_count, :integer
  end
end
