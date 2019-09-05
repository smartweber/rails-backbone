class AddLastSeenMessageIdToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :last_seen_message_id, :integer
  end
end
