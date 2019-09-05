class AddNewsItemTypeToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :news_item_type, :integer
  end
end
