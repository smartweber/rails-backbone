class RemovePeriodsFromUsernames < ActiveRecord::Migration
  def change
    User.where("username LIKE '%.%'").each do |u|
      u.update_attribute(:username, u.username.gsub('.', ''))
    end
  end
end
