collection @posts

extends "api/posts/_base"

child(:user) do
  attributes :id, :name, :username

  node(:gravatar_url) do |user|
    gravatar_url_for(user, size: 50)
  end
end

node(:comments) do
  []
end
