class ReindexAll < ActiveRecord::Migration
  def change
    Company.reindex
    Post.reindex
    User.reindex
  end
end
