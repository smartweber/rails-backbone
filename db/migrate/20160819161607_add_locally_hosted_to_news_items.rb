class AddLocallyHostedToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :locally_hosted, :boolean, default: false, null: false
  end
end
