attributes :id, :title, :body, :created_at, :position, :posts_count, :slug

node :thumbnail_url do |article|
  article.thumbnail.url
end
