class Post < ActiveRecord::Base
  include AttachableByUser
  include Mentionable
  include DestroyableWithDelay
  include Twitter::Extractor

  searchkick
  belongs_to :user
  belongs_to :article, polymorphic: true, counter_cache: true
  has_many :favorited_by_users, class_name: 'Favorite', dependent: :destroy
  has_many :comments, -> { order('created_at DESC').includes(:user).limit(3) }, as: :commentable
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :likes, as: :likeable, dependent: :destroy
  default_scope -> { not_schedule_for_deletion.order('created_at DESC') }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140, minimum: 1 }
  validate :picture_size
  validate :cashtags_amount

  after_create :increase_text_entities_counters
  after_commit :increment_feed_counters, on: :create

  attr_writer :text_entities

  # TODO: refactor
  scope :with_cashtag, ->(tag, page){ search(where: { cashtags: [tag], friends_only: false }, page: page, per_page: 20, include: [:user, :attachments, comments: [:attachments]], order: {created_at: :desc}) }
  scope :with_hashtag, ->(tag, page){ search(where: { hashtags: [tag], friends_only: false }, page: page, per_page: 20, include: [:user, :attachments, comments: [:attachments]], order: {created_at: :desc}) }
  scope :with_article_id_and_gt, ->(article_id, gt, page){ search(where: { article_id: article_id, article_type: 'Article', record_id: {gt: gt} }, page: page, per_page: 20, include: [:user, :attachments, comments: [:attachments]], order: {created_at: :desc}) }
  #scope :with_article_id_and_gt, ->(article_id, gt, page){ search(where: { article_id: article_id, article_type: 'Article', record_id: {gt: gt} }, page: page, per_page: 20, include: [:user, :attachments, comments: [:attachments]]) }
  scope :with_news_article_id_and_gt, ->(article_id, gt, page){ search(where: { article_id: article_id, article_type: 'GeneralNewsItem', record_id: {gt: gt} }, page: page, per_page: 20, include: [:user, :attachments, comments: [:attachments]], order: {created_at: :desc}) }
  scope :all_with_cashtag, ->(tag){ search(where: { cashtags: [tag], friends_only: false }) }
  scope :all_with_cashtag_gt, ->(tag, gt){ search(where: { cashtags: [tag], friends_only: false, record_id: {gt: gt} }, order: {created_at: :desc}) }
  scope :all_with_hashtag, ->(tag){ search(where: { hashtags: [tag], friends_only: false }) }
  scope :all_with_hashtag_gt, ->(tag, gt){ search(where: { hashtags: [tag], friends_only: false, record_id: {gt: gt} }, order: {created_at: :desc}) }
  scope :not_schedule_for_deletion, ->{ where.not(marked_for_deletion: true) }

  def Post.from_users_followed_by(user)
    following_ids = "SELECT followable_id FROM relationships WHERE follower_id = :user_id AND followable_type = 'User'"
    where("user_id IN (#{following_ids}) OR user_id = :user_id", following_ids: following_ids, user_id: user).includes(:user, comments: [:user])
  end

  def recent_comments(amount=3)
    comments.recent(amount)
  end

  def search_data
    {
      record_id: self.id,
      user_id: self.user_id,
      cashtags: cashtags,
      hashtags: hashtags,
      mentiontags: mentiontags,
      created_at: self.created_at,
      friends_only: self.friends_only,
      article_id: self.article_id,
      article_type: self.article_type
    }
  end

  def cashtags
    text_entities.select{|e| e.key?(:cashtag) }.collect!{|e| e[:cashtag] }
  end

  def hashtags
    text_entities.select{|e| e.key?(:hashtag) }.collect!{|e| e[:hashtag] }
  end

  def mentiontags
    text_entities.select{|e| e.key?(:screen_name) }.collect!{|e| e[:screen_name] }
  end

  def text_entities
    self['text_entities'] ? self['text_entities'] : self.text_entities = extract_entities_with_indices(self.content)
  end

  def favorited_by?(user)
    not favorited_by_users.where(user.id).first.nil?
  end

  def visible_for?(user)
    unless self.friends_only
      true
    else
      self.user_id == user.id or self.user.friends_with?(user)
    end
  end

  def increase_text_entities_counters
    {cashtags: cashtags, hashtags: hashtags, mentiontags: mentiontags}.each do |tag_type, tags|
      tags.each do |word|
        tag = Tag.find_or_create_by(tag_type: Tag::TYPES[tag_type], word: word)
        tag.taggings.create(post_id: self.id)
      end
    end
  end

  def increment_feed_counters
    push_tags_update('hashtags', 'channel')
    push_tags_update('cashtags', 'company')
    post_to_user_feeds
    post_to_user_command_feeds
    post_to_article_feed if self.article_id
  end

  def post_to_user_command_feeds
    company_followers = Company.where("abbr IN (?)", cashtags).map(&:followers)
    (self.user.followers + company_followers).flatten.uniq{ |u| u.id }.each do |follower|
      Bayeux.client.publish(Rails.application.routes.url_helpers.api_subscriptions_stream_path(follower.id, 'command'), {message_type: 'post_count_update', new_value: follower.feed_posts.size + 1, latest_post_id: self.id})
    end
  end

  def post_to_user_feeds
    Bayeux.client.publish(Rails.application.routes.url_helpers.api_subscriptions_stream_path(self.user_id, 'user'), {message_type: 'post_count_update', new_value: self.user.visible_posts_for(nil).size + 1, latest_post_id: self.id})
  end

  def post_to_article_feed
    article = self.article_type.constantize.find(self.article_id)
    Bayeux.client.publish(Rails.application.routes.url_helpers.api_subscriptions_stream_path(self.article_id, self.article_type.underscore), {message_type: 'post_count_update', new_value: article.posts_count + 1, latest_post_id: self.id})
  end

  def push_tags_update(tags_array_name, feedable_type)
    self.send(tags_array_name).each do |feedable_id|
      # TODO: invoke class method with metaprogramming
      count = case tags_array_name
      when 'hashtags'
        self.class.all_with_hashtag(feedable_id).total_count
      when 'cashtags'
        self.class.all_with_cashtag(feedable_id).total_count
      end
      Bayeux.client.publish(Rails.application.routes.url_helpers.api_subscriptions_stream_path(feedable_id, feedable_type), {message_type: 'post_count_update', new_value: count + 1, latest_post_id: self.id})
    end
  end

  def path_based_on_friendship
    if friends_only
      Rails.application.routes.url_helpers.api_subscriptions_friends_stream(user_id, 'user')
    else
      Rails.application.routes.url_helpers.api_subscriptions_shared_stream(user_id, 'user')
    end
  end

  private

    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5 MB")
      end
    end

    def cashtags_amount
      if cashtags.size > 3
        errors.add(:content, "Can't contain more than 3 cashtags")
      end
    end
end
