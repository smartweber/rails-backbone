child(:notifiable => :notifiable) do |notifiable|
  attributes :id, :name

  node(:gravatar_url) do |u|
    gravatar_url_for(u, size: 50)
  end
end
