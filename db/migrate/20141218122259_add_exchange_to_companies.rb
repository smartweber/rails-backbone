class AddExchangeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :exchange, :string
  end
end
