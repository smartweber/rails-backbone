class AddMuteUntilToTags < ActiveRecord::Migration
  def change
    add_column :tags, :mute_until, :datetime
  end
end
