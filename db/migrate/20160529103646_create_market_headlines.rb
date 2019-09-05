class CreateMarketHeadlines < ActiveRecord::Migration
  def change
    create_table :market_headlines do |t|
      t.string :title
      t.integer :position
      t.datetime :trending_until

      t.timestamps null: false
    end
  end
end
