class AddPostsCountToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :posts_count, :integer
  end
end
