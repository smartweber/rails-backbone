class ReindexCompaniesDueToWordSearchTypeAdded < ActiveRecord::Migration
  def change
    Company.reindex
  end
end
