class CreateMentions < ActiveRecord::Migration
  def change
    create_table :mentions do |t|
      t.integer :user_id, null: false
      t.references :mentionable, polymorphic: true, null: false

      t.timestamps null: false
    end
  end
end
