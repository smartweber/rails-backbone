attributes :id, :name, :username

node(:gravatar_url) do |u|
  gravatar_url_for(u, size: 50)
end
