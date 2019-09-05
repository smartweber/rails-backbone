class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.references :user
      t.references :micropost

      t.timestamps null: false
    end
    add_index :favorites, [:user_id, :micropost_id], unique: true
  end
end
