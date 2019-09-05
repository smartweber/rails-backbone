attributes :email, :created_at, :following_users_count, :followers_count, :collections_count, :ideas_count, :following_companies_count

extends('api/users/_base')

child @friendship => :friendship do
  extends('api/friendships/_base')
end
