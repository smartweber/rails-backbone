class AddCommentsCountToMicroposts < ActiveRecord::Migration
  def up
    add_column :microposts, :comments_count, :integer, default: 0

    Micropost.reset_column_information
    Micropost.all.each do |m|
      Micropost.update_counters m.id, comments_count: m.comments.unscope(:limit).length
    end
  end

  def down
    remove_column :microposts, :comments_count
  end
end
