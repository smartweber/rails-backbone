module UsersHelper

  #returns gravatar for given user
  def gravatar_for(user, options = {size: 80})
    image_tag(gravatar_url_for(user, options), alt: user.name, class: "gravatar")
  end

  def gravatar_url_for(user, options = {size: 80})
    return user.avatar.medium.url if user.avatar.url
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  end
end
