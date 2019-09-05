class SetDefaultNewsItemType < ActiveRecord::Migration
  def up
    GeneralNewsItem.unscoped.where(news_item_type: nil).find_each(batch_size: 100) do |gni|
      gni.update_columns(news_item_type: GeneralNewsItem::ITEM_TYPE)
    end
  end
end
