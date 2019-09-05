class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :body
      t.references :chat, index: true
      t.references :participant

      t.timestamps null: false
    end
  end
end
