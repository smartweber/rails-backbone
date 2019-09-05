require 'feedjira'

class FeedScraper
  include ActionView::Helpers::SanitizeHelper

  # how similar should be two sets of keywords to assume they're "matched"
  MAX_JI_DISTANCE = 0.7

  attr_accessor :feeds, :sources, :saved, :errors, :keywords_hash, :not_saved_news, :saved_news

  def initialize
    @sources        = APP_CONFIG[:feed_sources]
    @not_saved_news = {}
    @keywords_hash  = {}
    @saved_news     = []
    @errors         = []
    @feeds          = {}
  end

  def run
    fetch_news
    filter_outdated_news!
    process_news
  end

  private

    def fetch_news
      urls = sources.values.flatten
      for url in urls
        begin
          @feeds.merge!({ url => Feedjira::Feed.fetch_and_parse(url) })
        rescue StandardError => e
          Airbrake.notify(e, {url: url})
        end
      end
    end

    # @note advancing in minutes made to make sure that we won't throw away some news
    def filter_outdated_news!
      last_news_item_created_at = GeneralNewsItem.last.try(:created_at)
      feeds.each_pair do |url, feed|
        # it's not guaranteed that there's actual entries. It can be just a fixnum http status
        next unless feed.respond_to?(:entries)
        feed.entries.keep_if do |entry|
          entry.published > last_news_item_created_at.advance(minutes: -5) and entry.published > Time.now.advance(days: -1)
        end
      end if last_news_item_created_at
      feeds
    end

    def process_news
      parse_feeds
      update_duplicates_refs
    end

    def parse_feeds
      feeds.each_pair do |url, feed|
        next unless feed.respond_to?(:entries)
        feed.entries.each_with_index do |entry, index|
          agency = agency_name_by(url)
          new_entity = GeneralNewsItem.new(url: entry.url, title: entry.title, published_at: entry.published,
                                agency: agency, summary: entry.summary)
          if new_entity.valid?
            new_entity.set_keywords!
            merge_keywords_from(new_entity)
            merge_to_unsaved(new_entity)
          end
        end
      end
    end

    def agency_name_by(url)
      sources.select{|k, values| [values].flatten.include?(url)}.keys.first
    end

    def merge_to_unsaved(new_entity)
      not_saved_news.merge!({ new_entity.object_id.to_s(16) => new_entity })
    end

    def merge_keywords_from(news)
      [news].flatten.each do |news_item|
        keywords_hash.merge!(if news_item.persisted?
          { news_item.id => news_item.stemmed_keywords }
        else
          { news_item.object_id.to_s(16) => news_item.stemmed_keywords }
        end)
      end
    end

    def update_duplicates_refs
      @saved_news = GeneralNewsItem.where(news_subject_id: nil, created_at: Time.now.advance(days: -1)..Time.now.advance(seconds: 1)).to_a
      merge_keywords_from(saved_news)
      (saved_news + not_saved_news.values).flatten.each do |news_item|
        next unless news_item.news_subject_id.nil?
        best_match = find_best_match_for(news_item)
        if best_match[:distance] <= MAX_JI_DISTANCE
          news_item.news_subject = if best_match[:obj].news_subject_id.nil?
            best_match[:obj].create_news_subject
          else
            best_match[:obj].news_subject
          end
          best_match[:obj].save if best_match[:obj].changed?
        end
        news_item.save
      end
    end

    # compare keywords against other extracted from news items keyword-arrays
    def find_best_match_for(news_item)
      news_item_id = news_item.persisted? ? news_item.id : news_item.object_id.to_s(16)
      excluding_keywords_hash = keywords_hash.except(news_item_id)
      best_match_keywords = Jaccard.closest_to(news_item.stemmed_keywords, excluding_keywords_hash.values)
      unless best_match_keywords.nil? or best_match_keywords.empty?
        best_match_id = excluding_keywords_hash.key(best_match_keywords)
        best_match_obj = if best_match_id.is_a?(String)
          not_saved_news[best_match_id]
        else
          saved_news.select{|e| e.id == best_match_id}.first
        end
        {
          obj: best_match_obj,
          distance: Jaccard.distance(best_match_keywords, keywords_hash[news_item_id])
        }
      else
        # no possible candidates
        {
          obj: nil,
          distance: 1.0
        }
      end
    end
end
