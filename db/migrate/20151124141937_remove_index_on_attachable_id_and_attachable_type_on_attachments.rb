class RemoveIndexOnAttachableIdAndAttachableTypeOnAttachments < ActiveRecord::Migration
  def change
    remove_index :attachments, [:attachable_id, :attachable_type]
  end
end
