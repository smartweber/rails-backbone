class AddFollowedTypeToRelationships < ActiveRecord::Migration
  def change

    change_table(:relationships) do |t|
      t.rename :followed_id, :followable_id
      t.column :followable_type, :string
    end

    reversible do |dir|
      dir.up do
        Relationship.all.each do |r|
          r.update_attribute(:followable_type, "User")
        end
      end
    end
  end
end
