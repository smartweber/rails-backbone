object @user

extends 'api/users/_extended'
extends 'api/users/notifications/_index', locals: { notifications: @notifications }
