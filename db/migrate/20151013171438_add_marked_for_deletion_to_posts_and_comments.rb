class AddMarkedForDeletionToPostsAndComments < ActiveRecord::Migration
  def up
    add_column :posts, :marked_for_deletion, :boolean, default: false
    add_column :comments, :marked_for_deletion, :boolean, default: false
  end
end
