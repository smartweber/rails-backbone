collection @users, root: false, object_root: false

node(:followers_count) do |u|
  u.followers.count
end
node(:target_url) do |u|
  user_path(u.username)
end
extends('api/users/base')
