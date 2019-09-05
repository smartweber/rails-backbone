class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.integer :tag_type, null: false
      t.integer :taggings_count, default: 0, null: false
      t.string :word
      t.string :title
      t.string :description

      t.timestamps null: false
    end
  end
end
