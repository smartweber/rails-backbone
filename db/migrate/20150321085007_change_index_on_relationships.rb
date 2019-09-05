class ChangeIndexOnRelationships < ActiveRecord::Migration
  def change
    remove_index :relationships, [:follower_id, :followable_id]
    add_index :relationships, [:follower_id, :followable_id, :followable_type], unique: true, name: 'by_belonging'
  end
end
