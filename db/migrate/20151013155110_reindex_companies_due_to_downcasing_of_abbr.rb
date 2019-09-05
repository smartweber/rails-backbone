class ReindexCompaniesDueToDowncasingOfAbbr < ActiveRecord::Migration
  def change
    Company.reindex
  end
end
