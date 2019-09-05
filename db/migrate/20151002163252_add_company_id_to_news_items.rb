class AddCompanyIdToNewsItems < ActiveRecord::Migration
  def up
    add_reference :news_items, :company, index: true
  end

  def down
    remove_reference :news_items, :company
  end
end
