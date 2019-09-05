class RemoveDescriptionFromTags < ActiveRecord::Migration
  def change
    remove_column :tags, :description
  end
end
