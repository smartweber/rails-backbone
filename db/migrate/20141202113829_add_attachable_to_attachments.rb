class AddAttachableToAttachments < ActiveRecord::Migration
  def change
    add_reference :attachments, :attachable, polymorphic: true

    add_index(:attachments, [:attachable_id, :attachable_type], unique: true)
  end
end
