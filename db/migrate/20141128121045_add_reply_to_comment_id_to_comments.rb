class AddReplyToCommentIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :reply_to_comment_id, :integer
  end
end
