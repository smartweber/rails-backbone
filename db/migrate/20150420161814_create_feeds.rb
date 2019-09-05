class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.text :url
      t.string :title
      t.string :agency
      t.datetime :published_at

      t.timestamps null: false
    end

    add_index :feeds, :url, unique: true
  end
end
