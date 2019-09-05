class AddMoreColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :occupation, :string
    add_column :users, :education, :string
    add_column :users, :experience, :string
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float
    add_column :users, :location, :string
    add_column :users, :primary_investment_strategy, :string
    add_column :users, :average_investment_period, :string
  end
end
