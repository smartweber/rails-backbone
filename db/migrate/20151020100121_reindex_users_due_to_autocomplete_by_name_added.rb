class ReindexUsersDueToAutocompleteByNameAdded < ActiveRecord::Migration
  def change
    User.reindex
  end
end
