class CompanyNewsItem < NewsItem
  ITEM_TYPE = 1

  belongs_to :company

  validates_presence_of :title, :url, :published_at

  default_scope { where(news_item_type: ITEM_TYPE) }

  # TODO: Wrap in transaction
  def reposition
    if self.position
      unless self.trending_until_changed?
        trending_until = Time.current.advance(hours: (self.position_was.nil? ? 6 : 3))
        update_columns(trending_until: trending_until, updated_at: Time.current)
      end
      schedule_removal_from_trending
      if self.position.between?(1, 18) and self.news_thumbnail.url.nil?
        query        = self.not_stemmed_keywords.join(' ')
        first_result = GoogleApi.client.find_first_by(query)
        if first_result
          self.remote_news_thumbnail_url = first_result.link
          save
          # TODO: replace above with following once we've file storage set
          # GeneralNewsItemWorker.perform_async('fetch_google_image', self.id)
        end
      end
    elsif
      update_columns(trending_until: nil, updated_at: Time.current)
    end
  end

  def self.create_from_feed_item_and_company(fitem, company)
    create(title: fitem.title, published_at: fitem.published, url: fitem.url, company_id: company.id)
  end

  private

    def set_default_values
      self.news_item_type = ITEM_TYPE
    end
end
