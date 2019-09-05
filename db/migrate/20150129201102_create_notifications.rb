class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :notifiable, polymorphic: true
      t.references :user, null: false
      t.boolean :seen, default: false
      t.string :notification_type, default: "", null: false

      t.timestamps null: false
    end
  end
end
