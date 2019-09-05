class RenameFeedsToNewsItems < ActiveRecord::Migration
  def up
    remove_index :feeds, :url
    rename_table :feeds, :news_items
  end
end
