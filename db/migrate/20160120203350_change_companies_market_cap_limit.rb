class ChangeCompaniesMarketCapLimit < ActiveRecord::Migration
  def change
    change_column :companies, :market_cap, :integer, limit: 8
  end
end
