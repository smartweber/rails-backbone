require 'sanitize'

module ApplicationHelper
  #returns the full title on  a per page basis

  def full_title(page_title = '')
    base_title = "Stockharp - Financial Platform for Business News, Stock Market, Quotes & Insights"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def convert_specials_to_links(text)
    if text =~ /[@]/
      text.gsub!(/[@]([a-zA-Z0-9]+)/){|str| link_to_username(str)}
    end

    if text =~/[#]/
      text.gsub!(/[#]([a-zA-Z0-9_?]+)/){|str| link_to_hashtag(str)}
    end

    if text =~/[$]/
      text.gsub!(/[$]([a-zA-Z0-9.]+)/){|str| link_to_company(str)}
    end

    Sanitize.fragment text, elements: ['a'], attributes: {'a' => ['href', 'class']}
  end

  def link_to_username(tagged_name)
    name_with_stripped_tag = tagged_name[1..tagged_name.length]
    user = User.find_by_username(name_with_stripped_tag.downcase) # TODO: remove once url form is clear
    if user
      link_to '@'+user.titleized_name.gsub(' ',''), user_path(user), 'data-no-turbolink' => true, class: 'bb-post-link'
    else
      tagged_name
    end
  end

  def link_to_hashtag(hashtag)
    link_to hashtag, hashtag_path(hashtag.gsub('#', '')), 'data-no-turbolink' => true, class: 'bb-post-link'
  end

  def link_to_company(abbr)
    abbr_with_stripped_tag = abbr[1..abbr.length]
    company = Company.find_by_abbr(abbr_with_stripped_tag)
    if company
      link_to abbr.upcase, company_path(abbr[1..abbr.length]), class: 'bb-post-link'
    else
      abbr
    end
  end

  def popularity_button_for(likeable)
    like    = current_user.like_for(likeable)
    uniq_id = precreated_id_for(likeable)
    likes_count = likeable.likes_count > 0 ? likeable.likes_count : nil
    if like
      unlike_button_for(like, uniq_id, likes_count, likeable)
    else
      like_button_for(likeable, uniq_id, likes_count)
    end
  end

  def unlike_button_for(like, uniq_id, likes_count, likeable)
    link = link_to like, {method: :delete, "data-like-precreated-id" => uniq_id, 'data-like-id' => like.id, class: 'like-btn'} do
      content_tag(:span, class: 'glyphicon glyphicon-thumbs-down', 'aria-hidden' => true) do
        content_tag(:span, 'unlike')
      end
    end
    link + likes_counter(likes_count, likeable)
  end

  def like_button_for(likeable, uniq_id, likes_count)
    link = link_to likes_path, {"data-likeable-id" => likeable.id, "data-like-precreated-id" => uniq_id,
    "data-likeable-type" => likeable.class.to_s, class: 'like-btn'} do
      content_tag(:span, nil, class: 'glyphicon glyphicon-thumbs-up', 'aria-hidden' => true) do
        content_tag(:span, 'like')
      end
    end
    link + likes_counter(likes_count, likeable)
  end

  def likes_counter(likes_count, likeable)
    content_tag(:span, likes_count, "data-likeable-id" => likeable.id,
                 "data-likeable-type" => likeable.class.to_s, class: 'badge')
  end

  def friendship_indicator
    link_to 'Friend', '#', class: 'btn btn-success'
  end

  def precreated_id_for(element)
    "#{element.class}-#{element.id}"
  end
end
