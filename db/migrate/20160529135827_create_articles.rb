class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body
      t.integer :position
      t.datetime :trending_until

      t.timestamps null: false
    end
  end
end
