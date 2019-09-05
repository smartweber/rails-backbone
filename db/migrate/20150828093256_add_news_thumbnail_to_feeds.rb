class AddNewsThumbnailToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :news_thumbnail, :string
  end
end
