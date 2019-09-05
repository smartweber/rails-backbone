class AddPositionToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :position, :integer
  end
end
