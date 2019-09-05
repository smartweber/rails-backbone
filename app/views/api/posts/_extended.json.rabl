extends('api/posts/_base')

child(:user) do
  attributes :id, :name, :username

  node(:gravatar_url) do |user|
    gravatar_url_for(user, size: 50)
  end
end

child(:attachments) do
  attributes :id

  node :url do |attachment|
    attachment.image.thumb.url
  end
end

child(:comments) do
  extends 'api/comments/_base'
end
