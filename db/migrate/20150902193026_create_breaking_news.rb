class CreateBreakingNews < ActiveRecord::Migration
  def change
    create_table :breaking_news do |t|
      t.text :title
      t.datetime :trending_until

      t.timestamps null: false
    end
  end
end
