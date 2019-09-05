class Feed
  attr_accessor :feedable_type, :feedable_id, :posts, :current_user, :posts_total

  def initialize(feedable_id, feedable_type, current_user, args = {})
    @posts         = get_by_type_and_id(feedable_id, feedable_type, current_user, args)
    @feedable_id   = feedable_id
    @feedable_type = feedable_type
    @current_user  = current_user
  end

  def posts_count
    @posts_total ||= @posts.try(:total_count) || @posts.try(:size)
  end

  def get_by_type_and_id(feedable_id, feedable_type, current_user, args = {})
    case feedable_type
    when 'user'
      user = User.find(feedable_id)
      user.visible_posts_for(current_user, latest_post_id: args[:latest_post_id])
    when 'channel'
      if args[:latest_post_id]
        Post.all_with_hashtag_gt(feedable_id, args[:latest_post_id])
      else
        Post.all_with_hashtag(feedable_id)
      end
    when 'company'
      company      = Company.find_by_abbr!(feedable_id)
      @posts_total = Post.all_with_cashtag(feedable_id).total_count
      if args[:page]
        company.posts(args[:page])
      else
        Post.all_with_cashtag_gt(feedable_id, args[:latest_post_id])
      end
    when 'trending'
      Tagging.latest_posts_by_tags(Company.trending_company_abbrs)
    when 'command'
      @posts_total = current_user.feed_posts.size
      current_user.feed_posts(page: args[:page], latest_post_id: args[:latest_post_id])
    when 'article'
      Post.with_article_id_and_gt(feedable_id, args[:latest_post_id], args[:page])
    when 'news_article'
      Post.with_news_article_id_and_gt(feedable_id, args[:latest_post_id], args[:page])
    end
  end
end
