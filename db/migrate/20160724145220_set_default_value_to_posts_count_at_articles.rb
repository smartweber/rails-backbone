class SetDefaultValueToPostsCountAtArticles < ActiveRecord::Migration
  def up
    change_column_default(:articles, :posts_count, 0)
    Article.where(posts_count: nil).find_each(batch_size: 100) do |record|
      record.update_columns(posts_count: 0)
    end
    change_column_null(:articles, :posts_count, false)
  end
end
