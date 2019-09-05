class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\z/i
  VALID_NAME_REGEX = /\A(?!.*[\.\-]{2})(?!.*[\s]{2})[a-zA-Z]+[a-zA-Z\'\.\-\s]+\z/
  VALID_USERNAME_REGEX = /\A(?!.*[-]{2})[a-zA-Z0-9][a-zA-Z0-9-]*$\z/
  EXPERIENCES = %w(beginner intermediate experienced)
  PRIMARY_INVESTMENT_STRATEGIES = %w(fundamentals technical momentum growth value)
  AVERAGE_INVESTMENT_PERIODS = %w(short intermediate long)

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  searchkick word_start: [:username, :name]
  has_many :posts, dependent: :destroy
  has_many :created_comments, class_name: "Comment"
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship", dependent: :destroy, as: :followable
  has_many :following_users, through: :active_relationships, source: :followable, source_type: 'User'
  has_many :following_companies, through: :active_relationships, source: :followable, source_type: 'Company'
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :favorites
  has_many :favorited_posts, through: :favorites, source: 'post'
  has_many :likes
  has_many :mentions
  has_many :notifications
  has_many :participants
  has_many :chats, through: :participants
  before_save :downcase_email
  validates :tos_and_pp_accepted, acceptance: { accept: true }, on: :create, allow_nil: false
  validates :name, presence: true, length: { maximum: 50 }, format: { with: VALID_NAME_REGEX }
  validates :username, presence: true, format: { with: VALID_USERNAME_REGEX }, length: { minimum: 4, maximum: 15 },
                       uniqueness: { case_sensitive: false }
  validates :email, presence: true, length: { maximum: 100 }, format: { with: VALID_EMAIL_REGEX},
                    uniqueness: { case_sensitive: false }
  validates_inclusion_of :experience, in: EXPERIENCES, case_sensitive: false, allow_nil: true
  validates_inclusion_of :primary_investment_strategy, in: PRIMARY_INVESTMENT_STRATEGIES, case_sensitive: false, allow_nil: true
  validates_inclusion_of :average_investment_period, in: AVERAGE_INVESTMENT_PERIODS, case_sensitive: false, allow_nil: true

  mount_uploader :avatar, AvatarUploader

  def self.search_with_autocomplete(query)
    search(query, fields: [{username: :word_start}, {name: :word_start}], limit: 5)
  end

  def self.authenticate(email, password)
    user = where(email: email).first
    user.try(:valid_password?, password) ? user : false
  end

  def to_param
    self.username
  end

  def feed
    #this is preliminary. see following users for more
    Post.from_users_followed_by(self)
  end

  #follows a user
  def follow(followable)
    active_relationships.create(followable: followable)
  end

  #unfollows a user
  def unfollow(followable)
    active_relationships.find_by(followable_id: followable.id, followable_type: followable.class.to_s).destroy
  end

  #returns true if the current user is following the other user
  def following_user?(other_user)
    following_users.include?(other_user)
  end

  def following_company?(company)
    following_companies.include?(company)
  end

  #TODO: replace with counter caches
  def following_users_count
    following_users.count
  end

  def followers_count
    followers.count
  end

  def collections_count
    favorited_posts.count
  end

  def ideas_count
    posts.count
  end

  def following_companies_count
    following_companies.count
  end

  def mutually_following?(other_user)
    self.following_user?(other_user) && other_user.following_user?(self)
  end

  # TODO: alias it
  # returns true if current user is considering other_user as friend
  def friends_with?(other_user)
    self.mutually_following?(other_user)
  end

  def feed_posts(args = {})
    following_cashtags = self.following_companies.pluck(:abbr)
    following_user_ids = self.following_users.pluck(:id)
    mutual_friends_ids = self.mutual_relationships.collect!(&:follower_id)
    posts_search_conditions = {
      where: {
        or: [
          [{user_id: self.id}]
        ]
      },
      page: args[:page],
      per_page: 20,
      include: [:user, :attachments, comments: [:attachments]],
      order: {created_at: :desc}
    }
    if args[:latest_post_id]
      posts_search_conditions[:where].merge!({ record_id: {gt: args[:latest_post_id]} })
    end
    if args[:page].nil?
      posts_search_conditions.delete(:page); posts_search_conditions.delete(:per_page)
    end
    [{cashtags: following_cashtags, friends_only: false}, {user_id: following_user_ids,
      friends_only: false}, {user_id: mutual_friends_ids}].each do |or_hash|
        posts_search_conditions[:where][:or].first.push(or_hash) if or_hash.values.first.any?
      end
    public_results = Post.search(posts_search_conditions).results
  end

  # TODO: figure out better name that would be more describing about what side of relationship is returned
  def mutual_relationships
    Relationship.find_by_sql(["SELECT * from relationships t1 INNER JOIN relationships t2 ON (t1.follower_id = t2.followable_id) WHERE t1.follower_id = ? AND t1.id < t2.id AND t1.followable_type = 'User'", self.id])
  end

  # returns posts visible for user from feed of other user(self)
  def visible_posts_for(user, args = {})
    search_conditions = {
      where: {
        friends_only: false,
        user_id: self.id
      },
      page: args[:page],
      per_page: 20,
      include: [:user, :attachments, comments: [:attachments]],
      order: {created_at: :desc}
    }
    user = User.find(user) if user.is_a?(String) or user.is_a?(Fixnum)
    if args[:latest_post_id]
      search_conditions[:where].merge!({ record_id: {gt: args[:latest_post_id] }})
    end
    if (user and self.friends_with?(user)) or user == self
      search_conditions[:where].delete(:friends_only)
    end
    Post.search(search_conditions).results
  end

  def favorite(post)
    Favorite.create(user: self, post: post)
  end

  def unfavorite(post)
    self.favorites.find_by(post_id: post.id).destroy
  end

  def like_for(likeable)
    Like.where(likeable_id: likeable.id, likeable_type: likeable.class.to_s, user_id: self.id).first
  end

  def titleized_name
    name.gsub(' ','').titleize
  end

  private

    #converts email to all lower-case
    def downcase_email
      self.email = email.downcase
    end
end
