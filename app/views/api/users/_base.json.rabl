attributes :id, :name, :username

node(:gravatar_url) do |u|
  gravatar_url_for(u, size: 50)
end

node :relationship, if: self.try(:current_user) do
  partial('api/relationships/_base', object: current_user.active_relationships.where(followable: root_object).first)
end
