class AddKeywordsToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :keywords, :text
  end
end
