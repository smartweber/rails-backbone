class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :type_of_attachment
      t.string :title
      t.text :description
      t.string :image
    end
  end
end
