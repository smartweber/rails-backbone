attributes :id, :created_at

node(:content) do |m|
  convert_specials_to_links(m.content)
end

child(:user) do
  attributes :id, :name, :username

  node(:gravatar_url) do |user|
    gravatar_url_for(user, size: 50)
  end
end
