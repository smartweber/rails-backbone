attributes :id, :url, :agency, :locally_hosted, :news_thumbnail_carousel_list_url, :news_thumbnail_stretched_full_url, :slug

node(:title) do |f|
  f.title.truncate(120)
end

node(:sanitized_summary) do |f|
  f.sanitized_summary.truncate(200)
end

node(:summary) do |f|
  f.summary.truncate(200)
end
