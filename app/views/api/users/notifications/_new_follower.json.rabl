node :notifiable do |n|
  partial('api/users/notifications/_same_activity_participant', object: n.notifiable)
end

child(:other_recent_activity_participants) do |n|
  extends('api/users/notifications/_same_activity_participant')
end
