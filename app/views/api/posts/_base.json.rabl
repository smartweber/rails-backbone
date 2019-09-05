attributes :id, :created_at, :comments_count, :likes_count

node(:content) do |m|
  convert_specials_to_links(m.content)
end

# TODO: make it more obvious what's returned
node :favorited, if: current_user do |m|
  m.favorited_by?(current_user)
end

node(:like, if: current_user) do |c|
  partial 'api/likes/_base', object: current_user.like_for(c)
end
