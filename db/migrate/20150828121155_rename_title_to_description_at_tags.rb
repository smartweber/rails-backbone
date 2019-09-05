class RenameTitleToDescriptionAtTags < ActiveRecord::Migration
  def change
    rename_column :tags, :title, :description
  end
end
