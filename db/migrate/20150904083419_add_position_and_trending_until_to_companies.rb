class AddPositionAndTrendingUntilToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :position, :integer
    add_column :companies, :trending_until, :datetime
  end
end
