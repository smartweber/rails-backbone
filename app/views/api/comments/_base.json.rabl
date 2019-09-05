attributes :id, :commentable_id, :commentable_type, :created_at, :reply_to_comment_id, :user_id, :likes_count

node :body do |c|
  convert_specials_to_links(c.body)
end

child(:user) do
  extends "api/users/_extended"
end

child(:attachments) do
  attributes :id

  node :url do |attachment|
    attachment.image.thumb.url
  end
end

node(:like, if: current_user) do |c|
  partial 'api/likes/_base', object: current_user.like_for(c)
end
