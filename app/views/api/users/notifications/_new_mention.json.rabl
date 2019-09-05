child(:notifiable => :notifiable) do |notifiable|
  attributes :id

  node :entity_name do
    notifiable.class.to_s
  end

  child(:user) do
    attributes :id, :name, :username

    node(:gravatar_url) do |u|
      gravatar_url_for(u, size: 50)
    end
  end
end
