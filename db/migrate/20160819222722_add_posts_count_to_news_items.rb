class AddPostsCountToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :posts_count, :integer, default: 0, null: false
  end
end
