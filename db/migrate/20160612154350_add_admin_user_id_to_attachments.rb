class AddAdminUserIdToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :admin_user_id, :integer
  end
end
