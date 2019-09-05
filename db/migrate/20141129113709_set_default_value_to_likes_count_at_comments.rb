class SetDefaultValueToLikesCountAtComments < ActiveRecord::Migration
  def change
    change_column_default(:comments, :likes_count, 0)
  end
end
