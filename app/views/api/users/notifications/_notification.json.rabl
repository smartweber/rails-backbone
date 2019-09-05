attributes :id, :seen, :created_at
attribute :notification_type => :type

extends("api/users/notifications/_#{root_object.notification_type.downcase}")
