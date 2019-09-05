class AddSummaryToFeeds < ActiveRecord::Migration
  def change
    Feed.destroy_all
    add_column :feeds, :summary, :text
  end
end
