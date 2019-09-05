child(:notifiable => :notifiable) do |notifiable|
  attributes :id, :name, :username

  node :entity_name do
    'Post'
  end

  node(:gravatar_url) do |u|
    gravatar_url_for(u, size: 50)
  end
end
