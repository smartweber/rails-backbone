class AddTrendingUntilToFeedsAndTags < ActiveRecord::Migration
  def change
    add_column :feeds, :trending_until, :datetime
    add_column :tags, :trending_until, :datetime
  end
end
