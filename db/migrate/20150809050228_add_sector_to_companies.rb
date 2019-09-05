class AddSectorToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :sector, :string
  end
end
