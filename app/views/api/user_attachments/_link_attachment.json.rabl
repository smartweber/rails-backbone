attributes :id, :type_of_attachment, :image_url, :title, :description, :user_id

node :url do |attachment|
  shortened_path(attachment.shortened_urls.first.unique_key)
end

node :original_url do |attachment|
  attachment.shortened_urls.first.url
end
