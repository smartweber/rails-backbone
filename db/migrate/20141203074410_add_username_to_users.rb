class AddUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string, unique: true

    reversible do |dir|
      dir.up do
        User.all.each do |u|
          u.set_username
          u.update_attribute(:username, u.username)
        end
      end
    end
  end
end
