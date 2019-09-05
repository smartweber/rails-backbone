class RenameMicropostsToPosts < ActiveRecord::Migration
  def change
    rename_table :microposts, :posts

    rename_column :favorites, :micropost_id, :post_id

    Comment.where(commentable_type: 'Micropost').update_all(commentable_type: 'Post')
  end
end
