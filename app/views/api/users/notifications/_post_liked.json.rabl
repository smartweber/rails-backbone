child(:notifiable => :notifiable) do |notifiable|
  attributes :id, :name

  node :entity_name do |like|
    like.likeable.class.to_s
  end

  child :user do |u|
    attributes :name, :username
  end

  node(:gravatar_url) do |like|
    gravatar_url_for(like.user, size: 50)
  end
end

child(:other_recent_activity_participants) do |n|
  extends('api/users/notifications/_same_activity_participant')
end
